extends Control

signal restart_requested()

@onready var result_label: Label = $VBox/ResultLabel
@onready var restart_button: Button = $VBox/RestartButton


func _ready() -> void:
	restart_button.pressed.connect(func(): restart_requested.emit())


## result: Enums.FailType value, or -1 for a win.
func set_result(result: int) -> void:
	match result:
		-1:
			result_label.text = "The debt is paid. You made it through."
		Enums.FailType.WRONG_READ:
			result_label.text = "You let the wrong person in.\n\n[Wrong Read]"
		Enums.FailType.COLLATERAL_PHYSICALITY:
			result_label.text = "Someone who needed you got hurt instead.\n\n[Collateral Physicality]"
		Enums.FailType.DEPENDENT_DECLINE:
			result_label.text = "You couldn't keep them safe.\n\n[Dependent Decline]"
		_:
			result_label.text = "The night is over."
