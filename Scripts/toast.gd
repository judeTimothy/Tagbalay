extends Node2D
var label_text = "This is a toast test."
var floating = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationTree.play("Dissolve")
	if floating:
		$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if floating:
		position.y -= 0.05

func display_text(text):
	$Sprite2D/Label.text = text


func _on_timer_timeout() -> void:
	queue_free()
