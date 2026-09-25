extends Control
@onready var creepy_bgm = preload("res://Assets/Music/(4) Creepy Ambience.ogg")
@onready var hover_sfx = preload("res://Assets/Sounds/Menu_Hover_Selection.ogg")
@onready var select_sfx = preload("res://Assets/Sounds/Menu_Click_Selection.ogg")
@onready var next_sfx = preload("res://Assets/Sounds/Game_Next Scene_Click_Selection.ogg")
@onready var knock_sfx = preload("res://Assets/Sounds/Knock.ogg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Black_to_View")
	$CanvasLayer/Color.color = Color.BLACK
	#$AnimationPlayer.play("Intro")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bgm_finished() -> void:
	$BGM.play()


func _on_static_finished() -> void:
	$Static.play()


func _on_button_mouse_entered() -> void:
	$Play/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_button_mouse_exited() -> void:
	$Play/Label.add_theme_color_override("font_color",Color.from_rgba8(6,82,117,255))


func _on_play_pressed() -> void:
	$SFX.stream = next_sfx
	$SFX.play()
	$AnimationPlayer.play("Fade_to_Black")
	$Timer.start()


func _on_timer_timeout() -> void:
	Autoloads.main_bgm_seek = $BGM.get_playback_position()
	get_tree().change_scene_to_file("res://Scenes/DoorScene.tscn")


func _on_intro_timer_timeout() -> void:
	$AnimationPlayer.play("Black_to_View")
	$Static.play()


func _on_start_timeout() -> void:
	$AnimationPlayer.play("Intro")
	$BGM.play()
