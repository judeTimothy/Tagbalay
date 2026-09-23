extends Node
## Attached to Main.tscn's root node.
## Owns nothing about game rules — just swaps phase scenes in and out and
## reacts to RunState's win/fail signals. All actual logic lives in the
## RunState / DayManager / NightManager autoloads.

const DAY_PHASE_SCENE := preload("res://scenes/DayPhase.tscn")
const NIGHT_PHASE_SCENE := preload("res://scenes/NightPhase.tscn")
const END_SCREEN_SCENE := preload("res://scenes/EndScreen.tscn")

@onready var phase_container: Node = $PhaseContainer

var current_phase_node: Node = null


func _ready() -> void:
	RunState.fail_triggered.connect(_on_fail_triggered)
	RunState.run_won.connect(_on_run_won)
	RunState.init_new_run()
	_start_day_phase()


func _start_day_phase() -> void:
	_clear_phase_container()
	var day_phase := DAY_PHASE_SCENE.instantiate()
	phase_container.add_child(day_phase)
	current_phase_node = day_phase
	day_phase.day_ended.connect(_on_day_ended)


func _on_day_ended() -> void:
	DayManager.end_day()
	# end_day() can itself trigger dependent_decline (RunState.fail_triggered),
	# which _on_fail_triggered already handles by swapping to the end screen.
	# Guard against also starting a night phase on top of that:
	if RunState.dependent_condition <= 0.0:
		return
	_start_night_phase()


func _start_night_phase() -> void:
	_clear_phase_container()
	var night_phase := NIGHT_PHASE_SCENE.instantiate()
	phase_container.add_child(night_phase)
	current_phase_node = night_phase
	night_phase.night_ended.connect(_on_night_ended)


func _on_night_ended() -> void:
	_start_day_phase()


func _on_fail_triggered(fail_type: int) -> void:
	_start_end_screen(fail_type)


func _on_run_won() -> void:
	_start_end_screen(-1)  # -1 == win, not a FailType


func _start_end_screen(result: int) -> void:
	_clear_phase_container()
	var end_screen := END_SCREEN_SCENE.instantiate()
	phase_container.add_child(end_screen)
	end_screen.name = "EndScreenInstance"
	current_phase_node = end_screen
	end_screen.set_result(result)
	end_screen.restart_requested.connect(_on_restart_requested)


func _on_restart_requested() -> void:
	RunState.init_new_run()
	_start_day_phase()


func _clear_phase_container() -> void:
	for child in phase_container.get_children():
		child.queue_free()
