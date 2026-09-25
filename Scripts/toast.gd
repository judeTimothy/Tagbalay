extends Node2D
var label_text = "This is a toast test."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationTree.play("Dissolve")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y -= 0.05

func display_text(text):
	$Sprite2D/Label.text = text


func _on_timer_timeout() -> void:
	queue_free()
