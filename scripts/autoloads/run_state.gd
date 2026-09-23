extends Node
# Autoload "RunState" — the single source of truth for one playthrough.
# DayManager and NightManager read/write this. UI listens to its signals.

# --- Core resources ---
var money: int = 0
var trust: float = 0.5            # 0-1, improves tell clarity when high
var composure: float = 0.5        # 0-1, affects read-accuracy variance
var dependent_condition: float = 1.0   # 0-1, 0 = fail state

# --- Debt ---
var debt_total: int = 0
var debt_remaining: int = 0
var cumulative_payments: int = 0
var predator_threshold: int = 0
var payments_needed: int = 0       # scales installment size so pacing stays consistent

# --- Cycle tracking ---
var current_cycle: int = 0
var cycles_since_last_payment: int = 0

# --- Legit escalation ---
var legit_aggression: float = 0.2

# --- Affected persons runtime state ---
# person_id -> { "exposure_state": Enums.ExposureState, "trust_level": float,
#                "is_accepted_helper": bool }
var affected_persons: Dictionary = {}
var accepted_helper_id: String = ""

# --- House reinforcement flags (set by DayManager, read by NightManager) ---
var has_better_lock: bool = false
var has_outside_light: bool = false

signal debt_changed(new_remaining: int)
signal money_changed(new_amount: int)
signal dependent_condition_changed(new_value: float)
signal predator_unlocked()
signal fail_triggered(fail_type: int)   # Enums.FailType
signal run_won()


func init_new_run() -> void:
	debt_total = randi_range(8000, 25000)
	debt_remaining = debt_total
	payments_needed = randi_range(5, 9)
	predator_threshold = int(debt_total * 0.4)

	money = randi_range(500, 1500)
	trust = 0.5
	composure = 0.5
	dependent_condition = 1.0

	current_cycle = 0
	cycles_since_last_payment = 0
	legit_aggression = 0.2

	accepted_helper_id = ""
	has_better_lock = false
	has_outside_light = false

	_init_affected_persons()

	debt_changed.emit(debt_remaining)
	money_changed.emit(money)
	dependent_condition_changed.emit(dependent_condition)


func _init_affected_persons() -> void:
	affected_persons.clear()
	for pid in ["tita_baby", "kuya_jun", "ate_marites"]:
		affected_persons[pid] = {
			"exposure_state": Enums.ExposureState.UNAWARE,
			"trust_level": 0.5,
			"is_accepted_helper": false,
		}


## Returns the amount asked for on the current installment.
## Randomized within a band around the "fair" per-installment share,
## so no two runs (or even two visits) ask for identical numbers.
func get_installment_amount() -> int:
	var remaining_installments: int = max(1, payments_needed - _installments_paid())
	var fair_share: int = int(float(debt_remaining) / float(remaining_installments))
	var jitter: float = randf_range(0.8, 1.2)
	return max(200, int(fair_share * jitter))


func _installments_paid() -> int:
	if debt_total <= 0:
		return payments_needed
	var paid_ratio: float = 1.0 - (float(debt_remaining) / float(debt_total))
	return int(round(paid_ratio * payments_needed))


func apply_payment(amount: int, recipient_type: int) -> void:
	amount = min(amount, money)
	money -= amount
	money_changed.emit(money)

	if recipient_type == Enums.VisitorType.LEGIT:
		debt_remaining = max(0, debt_remaining - amount)
		cycles_since_last_payment = 0
		debt_changed.emit(debt_remaining)
		if debt_remaining == 0:
			run_won.emit()
	# FRAUD: money is simply gone, debt untouched — no-op beyond the deduction above.
	# HELPER (repayment installments once accepted): treat like a Legit-equivalent
	# reduction against the personal-obligation ledger; for jam scope we fold it
	# into debt_remaining too, since "the debt" is what the player is chasing to zero.
	elif recipient_type == Enums.VisitorType.HELPER:
		debt_remaining = max(0, debt_remaining - amount)
		debt_changed.emit(debt_remaining)
		if debt_remaining == 0:
			run_won.emit()

	cumulative_payments += amount
	if cumulative_payments >= predator_threshold:
		predator_unlocked.emit()


func refuse_legit() -> void:
	cycles_since_last_payment += 1
	legit_aggression = min(1.0, legit_aggression + 0.1)


func accept_helper(person_id: String) -> void:
	accepted_helper_id = person_id
	if affected_persons.has(person_id):
		affected_persons[person_id]["is_accepted_helper"] = true


func raise_exposure(person_id: String) -> void:
	if not affected_persons.has(person_id):
		return
	var state: int = affected_persons[person_id]["exposure_state"]
	affected_persons[person_id]["exposure_state"] = min(state + 1, Enums.ExposureState.THREATENED)


func adjust_dependent_condition(delta: float) -> void:
	dependent_condition = clamp(dependent_condition + delta, 0.0, 1.0)
	dependent_condition_changed.emit(dependent_condition)
	if dependent_condition <= 0.0:
		fail_triggered.emit(Enums.FailType.DEPENDENT_DECLINE)


func trigger_fail(fail_type: int) -> void:
	fail_triggered.emit(fail_type)
