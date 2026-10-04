extends Node2D

var can_click = false
var has_clicked = false


func _ready() -> void:
	$AnimationPlayer.play("credits")
	_start_idle_sway()

func _process(delta: float) -> void:
	if Input.is_action_pressed("click"):
		if can_click == true and has_clicked == false:
			$Timer.start()
			$AnimationPlayer.play("Fade_to_Black")
			has_clicked = true
			Autoloads.reset_game_state()
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		

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


func _on_timer_timeout() -> void:
	$UI/Press.visible = true
	can_click = true


func _on_auto_timer_timeout() -> void:
	Autoloads.reset_game_state()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
