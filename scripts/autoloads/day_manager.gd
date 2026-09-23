extends Node
# Autoload "DayManager" — pure logic for the day/prep phase.
# DayPhaseController calls perform_action() per button press, then end_day()
# when the player is done with their morning.

signal action_performed(action: int, success: bool)  # Enums.DayAction


func perform_action(action: int) -> bool:
	match action:
		Enums.DayAction.WORK:
			RunState.money += randi_range(300, 600)
			RunState.money_changed.emit(RunState.money)
			action_performed.emit(action, true)
			return true

		Enums.DayAction.GATHER_INTEL:
			RunState.trust = min(1.0, RunState.trust + 0.1)
			action_performed.emit(action, true)
			return true

		Enums.DayAction.REST:
			RunState.composure = min(1.0, RunState.composure + 0.2)
			action_performed.emit(action, true)
			return true

		Enums.DayAction.CARE_FOR_DEPENDENT:
			if RunState.money < 200:
				action_performed.emit(action, false)
				return false
			RunState.money -= 200
			RunState.money_changed.emit(RunState.money)
			RunState.adjust_dependent_condition(0.15)
			action_performed.emit(action, true)
			return true

		Enums.DayAction.REINFORCE_HOUSE:
			if RunState.money < 500:
				action_performed.emit(action, false)
				return false
			RunState.money -= 500
			RunState.money_changed.emit(RunState.money)
			if not RunState.has_outside_light:
				RunState.has_outside_light = true
			elif not RunState.has_better_lock:
				RunState.has_better_lock = true
			action_performed.emit(action, true)
			return true

	return false


## Called once when the player is done with the day and moves to night.
func end_day() -> void:
	# Passive dependent decay if uncared-for — makes CARE_FOR_DEPENDENT a real
	# recurring choice rather than a one-time fix.
	RunState.adjust_dependent_condition(-0.05)

	# Affected-person exposure creeps up on its own if the player never engages
	# with the debt at all (mirrors "word gets around" pressure).
	if RunState.cycles_since_last_payment >= 2:
		for pid in RunState.affected_persons.keys():
			if pid != RunState.accepted_helper_id:
				RunState.raise_exposure(pid)

	RunState.current_cycle += 1
