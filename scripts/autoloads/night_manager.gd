extends Node
# Autoload "NightManager" — pure logic for the night/gate phase.
# NightPhaseController drives this via start_night() / player action calls,
# and listens to its signals to update the UI.

const CONTENT_ROOT := "res://content/visitors/"

signal visitor_arrived(visitor: VisitorProfile, tells: Array)
signal visit_resolved(visitor: VisitorProfile, outcome: int, action: int)  # Enums.VisitorOutcome/PlayerAction
signal night_complete()

var visits_this_night: int = 3
var _queue: Array[VisitorProfile] = []
var current_visitor: VisitorProfile = null
var current_tells: Array = []
var _payment_amount: int = 0


func start_night() -> void:
	visits_this_night = 3 if RunState.current_cycle < 3 else 4
	_queue = _build_pool_for_cycle()
	_advance_queue()


func _advance_queue() -> void:
	if _queue.is_empty():
		night_complete.emit()
		return
	current_visitor = _queue.pop_front()
	current_tells = current_visitor.get_random_tells()
	_payment_amount = RunState.get_installment_amount()
	visitor_arrived.emit(current_visitor, current_tells)


## Called by NightPhaseController when the player picks an action for the
## current visitor. Returns the outcome so the UI can react immediately;
## the signal is emitted too, for anything else listening (audio, etc).
func resolve_visit(action: int) -> int:
	var visitor := current_visitor
	var outcome: int = Enums.VisitorOutcome.SAFE

	match action:
		Enums.PlayerAction.LET_IN:
			if visitor.fatal_if_let_in:
				if visitor.visitor_type == Enums.VisitorType.PREDATOR:
					outcome = Enums.VisitorOutcome.WRONG_READ
					RunState.trigger_fail(Enums.FailType.WRONG_READ)
				else:
					outcome = Enums.VisitorOutcome.WRONG_READ
					RunState.trigger_fail(Enums.FailType.WRONG_READ)
			# else: letting in a safe visitor (Helper, or a Collateral-Physicality
			# visit gone right) is a legitimate, non-fatal choice — no penalty.

		Enums.PlayerAction.PAY:
			if visitor.can_be_paid:
				RunState.apply_payment(_payment_amount, visitor.visitor_type)
				outcome = Enums.VisitorOutcome.SAFE
			else:
				# Predator doesn't want money — offering it is a no-op, not a
				# trap, but it doesn't satisfy them either. They keep pressing.
				outcome = Enums.VisitorOutcome.SAFE

		Enums.PlayerAction.REFUSE:
			if visitor.visitor_type == Enums.VisitorType.LEGIT:
				RunState.refuse_legit()
			elif visitor.visitor_type == Enums.VisitorType.HELPER \
					and _is_collateral_physicality_visit(visitor):
				# Turning away a helper who arrived in crisis, when they needed
				# you to act, is how a Collateral Physicality visit goes wrong.
				outcome = Enums.VisitorOutcome.COLLATERAL_PHYSICALITY
				RunState.trigger_fail(Enums.FailType.COLLATERAL_PHYSICALITY)
			outcome = Enums.VisitorOutcome.SAFE if outcome == Enums.VisitorOutcome.SAFE else outcome

	visit_resolved.emit(visitor, outcome, action)

	if outcome != Enums.VisitorOutcome.SAFE:
		# A fail state ends the night (and the run) immediately — don't advance.
		return outcome

	_advance_queue()
	return outcome


func get_current_payment_amount() -> int:
	return _payment_amount


func _is_collateral_physicality_visit(visitor: VisitorProfile) -> bool:
	return visitor.linked_person_id != "" \
		and visitor.linked_person_id != RunState.accepted_helper_id \
		and RunState.affected_persons.get(visitor.linked_person_id, {}) \
			.get("exposure_state", Enums.ExposureState.UNAWARE) == Enums.ExposureState.THREATENED


# ---------------------------------------------------------------------------
# Pool construction
# ---------------------------------------------------------------------------

func _build_pool_for_cycle() -> Array[VisitorProfile]:
	var pool: Array[VisitorProfile] = []

	var legit := _pick_random_from_dir("legit/")
	if legit:
		pool.append(legit)

	if RunState.cumulative_payments >= RunState.predator_threshold:
		var predator := _pick_random_from_dir("predator/")
		if predator:
			pool.append(predator)
	else:
		var fraud := _pick_random_from_dir("fraud/")
		if fraud:
			pool.append(fraud)

	var helper_or_crisis := _roll_helper_slot()
	if helper_or_crisis:
		pool.append(helper_or_crisis)

	pool.shuffle()

	# Pad or trim to visits_this_night by repeating Legit if the content
	# pool is thin (fine for a jam-scope early build with few .tres files).
	while pool.size() < visits_this_night and legit:
		pool.append(legit)
	if pool.size() > visits_this_night:
		pool = pool.slice(0, visits_this_night)

	if pool.is_empty():
		push_warning(
			"NightManager: visitor pool is EMPTY for this cycle — no .tres " +
			"files were found under res://content/visitors/. Night will " +
			"complete instantly and silently return to Day, which looks " +
			"exactly like the button did nothing. Check that the content/ " +
			"folder exists next to project.godot, not nested a level deeper."
		)

	return pool


func _roll_helper_slot() -> VisitorProfile:
	# Already-accepted helper: still shows sometimes, for repayment interactions.
	if RunState.accepted_helper_id != "":
		if randf() < 0.4:
			return _load_helper_profile(RunState.accepted_helper_id)
		return null

	# No helper accepted yet: any of the 3 may offer, OR the one whose
	# exposure has reached THREATENED becomes the Collateral Physicality visit.
	for pid in RunState.affected_persons.keys():
		var state: int = RunState.affected_persons[pid]["exposure_state"]
		if state == Enums.ExposureState.THREATENED:
			return _load_helper_profile(pid)  # arrives in crisis, not offering help

	if randf() < 0.5:
		var candidates := RunState.affected_persons.keys()
		candidates.shuffle()
		return _load_helper_profile(candidates[0])

	return null


func _load_helper_profile(person_id: String) -> VisitorProfile:
	var path := CONTENT_ROOT + "helper/" + person_id + ".tres"
	if ResourceLoader.exists(path):
		return load(path) as VisitorProfile
	return null


func _pick_random_from_dir(subdir: String) -> VisitorProfile:
	var dir_path := CONTENT_ROOT + subdir
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("NightManager: content dir not found: " + dir_path)
		return null

	var files: Array[String] = []
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if f.ends_with(".tres"):
			files.append(f)
		f = dir.get_next()
	dir.list_dir_end()

	if files.is_empty():
		return null
	files.shuffle()
	return load(dir_path + files[0]) as VisitorProfile
