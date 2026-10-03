extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("credits")
	_start_idle_sway()


func _start_idle_sway() -> void:
	var sprite := $UI/MovingContainer
	var base_pos: Vector2 = sprite.position
 
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "position", base_pos + Vector2(3, -2), 1.6)
	tween.tween_property(sprite, "position", base_pos + Vector2(-3, 2), 1.6)
	tween.tween_property(sprite, "position", base_pos, 1.6)
