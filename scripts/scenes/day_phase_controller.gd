extends Control
## Attached to DayPhase.tscn root. Placeholder UI (Labels + Buttons) —
## your art guy swaps the visuals, this script's public surface doesn't change.
##
## Day rule: pick exactly ONE of Work / Chismis / Rest — picking one locks
## the other two (and itself) but does NOT advance the day by itself.
## Care is fully independent: usable once per day, any time, never locked
## by picking a primary action. "Go to the gate" only unlocks once a
## primary action has been chosen, and is the sole way to end the day.

signal day_ended()

@onready var money_label: Label = $VBox/StatsBox/MoneyLabel
@onready var debt_label: Label = $VBox/StatsBox/DebtLabel
@onready var dependent_label: Label = $VBox/StatsBox/DependentLabel
@onready var trust_label: Label = $VBox/StatsBox/TrustLabel
@onready var composure_label: Label = $VBox/StatsBox/ComposureLabel
@onready var cycle_label: Label = $VBox/StatsBox/CycleLabel
@onready var feedback_label: Label = $VBox/FeedbackLabel

@onready var work_button: Button = $VBox/ActionsBox/WorkButton
@onready var intel_button: Button = $VBox/ActionsBox/IntelButton
@onready var rest_button: Button = $VBox/ActionsBox/RestButton
@onready var care_button: Button = $VBox/ActionsBox/CareButton
@onready var go_to_night_button: Button = $VBox/GoToNightButton

var _primary_action_used: bool = false
var _care_used: bool = false


func _ready() -> void:
	work_button.pressed.connect(func(): _do_primary_action(Enums.DayAction.WORK))
	intel_button.pressed.connect(func(): _do_primary_action(Enums.DayAction.GATHER_INTEL))
	rest_button.pressed.connect(func(): _do_primary_action(Enums.DayAction.REST))
	care_button.pressed.connect(_do_care_action)
	go_to_night_button.pressed.connect(func(): day_ended.emit())
	_refresh_stats()


## Work / Chismis / Rest — pick exactly one. This locks the three primary
## buttons against each other (and itself, since it's already been used)
## and unlocks "Go to the gate", but does NOT touch Care or end the day.
func _do_primary_action(action: int) -> void:
	if _primary_action_used:
		return
	_primary_action_used = true
	DayManager.perform_action(action)
	feedback_label.text = "Done. You can still Care before heading out, or go now."
	_refresh_stats()

	work_button.disabled = true
	intel_button.disabled = true
	rest_button.disabled = true
	go_to_night_button.disabled = false
	# Deliberately NOT touching care_button here.


## Care — usable once per day, independent of the primary-action lock,
## never disabled by picking Work/Chismis/Rest.
func _do_care_action() -> void:
	if _care_used:
		return
	var success: bool = DayManager.perform_action(Enums.DayAction.CARE_FOR_DEPENDENT)
	if success:
		_care_used = true
		care_button.disabled = true
		feedback_label.text = "Cared for them."
	else:
		feedback_label.text = "Not enough money to care for them."
	_refresh_stats()


func _refresh_stats() -> void:
	money_label.text = "Money: ₱%d" % RunState.money
	debt_label.text = "Debt remaining: ₱%d / ₱%d" % [RunState.debt_remaining, RunState.debt_total]
	dependent_label.text = "Dependent condition: %d%%" % int(RunState.dependent_condition * 100)
	trust_label.text = "Trust: %d%%" % int(RunState.trust * 100)
	composure_label.text = "Composure: %d%%" % int(RunState.composure * 100)
	cycle_label.text = "Day %d" % (RunState.current_cycle + 1)
