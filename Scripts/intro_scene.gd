extends Control

@onready var yume = preload("res://Assets/Backgrounds/yume_tagbalay.png")
@onready var warning = preload("res://Assets/Backgrounds/warning.png")
@onready var disclaimer = preload("res://Assets/Backgrounds/disclaimer.png")
@onready var headphones = preload("res://Assets/Backgrounds/headphones.png")

var state = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		1:
			$TextureRect.texture = yume
		2:
			$TextureRect.texture = warning
			$Timer.wait_time = 2.5
		3:
			$TextureRect.texture = disclaimer
			$Timer.wait_time = 3.8
		4:
			$TextureRect.texture = headphones
			$Timer.wait_time = 2.8
			


func _on_timer_timeout() -> void:
	if state < 4:
		state += 1
	else:
		Autoloads.current_bgm_seek = $BGM.get_playback_position()
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
