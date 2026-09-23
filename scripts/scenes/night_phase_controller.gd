extends Control
## Attached to NightPhase.tscn root. Placeholder UI — portrait swap is just
## a TextureRect, dialogue is a RichTextLabel. Talk reveals tells one at a
## time instead of dumping them all at once, so reading takes real attention.

signal night_ended()

@onready var portrait: TextureRect = $VBox/Portrait
@onready var name_label: Label = $VBox/NameLabel
@onready var dialogue_label: RichTextLabel = $VBox/DialogueLabel
@onready var receipt_label: Label = $VBox/ReceiptLabel
@onready var payment_label: Label = $VBox/PaymentLabel

@onready var pay_button: Button = $VBox/ActionsBox/PayButton
@onready var refuse_button: Button = $VBox/ActionsBox/RefuseButton
@onready var let_in_button: Button = $VBox/ActionsBox/LetInButton
@onready var talk_button: Button = $VBox/ActionsBox/TalkButton

var _revealed_tell_count: int = 0


func _ready() -> void:
	pay_button.pressed.connect(func(): _resolve(Enums.PlayerAction.PAY))
	refuse_button.pressed.connect(func(): _resolve(Enums.PlayerAction.REFUSE))
	let_in_button.pressed.connect(func(): _resolve(Enums.PlayerAction.LET_IN))
	talk_button.pressed.connect(_on_talk_pressed)

	NightManager.visitor_arrived.connect(_on_visitor_arrived)
	NightManager.visit_resolved.connect(_on_visit_resolved)
	NightManager.night_complete.connect(_on_night_complete)

	NightManager.start_night()


func _on_visitor_arrived(visitor: VisitorProfile, _tells: Array) -> void:
	_revealed_tell_count = 0
	name_label.text = "Someone's at the gate."   # deliberately vague pre-Talk
	portrait.texture = visitor.portrait_silhouette
	dialogue_label.text = _line_text(visitor.greet_lines)

	receipt_label.text = "Owed to: %s\nBalance: ₱%d / ₱%d" % [
		"[lender name TODO]", RunState.debt_remaining, RunState.debt_total
	]
	payment_label.text = "They're asking for: ₱%d" % NightManager.get_current_payment_amount()

	pay_button.disabled = not visitor.can_be_paid
	_set_buttons_enabled(true)


func _on_talk_pressed() -> void:
	var visitor := NightManager.current_visitor
	var tells: Array = NightManager.current_tells
	if _revealed_tell_count < tells.size():
		var tell: TellData = tells[_revealed_tell_count]
		dialogue_label.text += "\n\n[i]%s[/i]" % tell.tell_text
		_revealed_tell_count += 1
	else:
		dialogue_label.text += "\n\n...They're waiting for your answer."
	if _revealed_tell_count >= tells.size():
		talk_button.disabled = true


func _resolve(action: int) -> void:
	_set_buttons_enabled(false)
	NightManager.resolve_visit(action)


func _on_visit_resolved(_visitor: VisitorProfile, outcome: int, _action: int) -> void:
	if outcome != Enums.VisitorOutcome.SAFE:
		# Fail handled by RunState.fail_triggered -> Main.gd swaps to EndScreen.
		return
	# Safe outcome: brief pause before next visitor could go here (timer/tween).
	# Kept synchronous for the barebones prototype.


func _on_night_complete() -> void:
	night_ended.emit()


func _set_buttons_enabled(enabled: bool) -> void:
	pay_button.disabled = not enabled
	refuse_button.disabled = not enabled
	let_in_button.disabled = not enabled
	talk_button.disabled = not enabled


func _line_text(lines: Array) -> String:
	if lines.is_empty():
		return "..."
	var line: VisitorLine = lines[randi() % lines.size()]
	return line.text
