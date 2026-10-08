extends Node2D
@onready var achievement = preload("res://Scenes/achievement.tscn")

func _ready() -> void:
	$AnimationPlayer.play("death")
	var b = achievement.instantiate()
	b.achievement = 2
	$UI/CanvasLayer/Color.add_child(b)
	_start_idle_sway()


func _start_idle_sway() -> void:
	var sprite := $TextureRect
	var base_pos: Vector2 = sprite.position

	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(sprite, "position", base_pos + Vector2(10, -4), 0.8)
	tween.tween_property(sprite, "position", base_pos + Vector2(-7, 5), 1.0)
	tween.tween_property(sprite, "position", base_pos + Vector2(5, -7), 0.9)
	tween.tween_property(sprite, "position", base_pos + Vector2(-10, 3), 1.1)
	tween.tween_property(sprite, "position", base_pos, 0.8)


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
