extends Control
@onready var creepy_bgm = preload("res://Assets/Music/(4) Creepy Ambience.ogg")
@onready var hover_sfx = preload("res://Assets/Sounds/Menu_Hover_Selection.ogg")
@onready var select_sfx = preload("res://Assets/Sounds/Menu_Click_Selection.ogg")
@onready var next_sfx = preload("res://Assets/Sounds/Game_Next Scene_Click_Selection.ogg")
@onready var knock_sfx = preload("res://Assets/Sounds/Knock.ogg")


var can_click = false
var has_clicked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BGM.play(Autoloads.current_bgm_seek)
	$AnimationPlayer.play("Black_to_View")
	$CanvasLayer/Color.color = Color.BLACK
	#$AnimationPlayer.play("Intro")

func _process(delta: float) -> void:
	if Input.is_action_pressed("click"):
		if can_click == true and has_clicked == false:
			$Timer.start()
			$CanvasLayer/Press.visible = false
			$AnimationPlayer.play("Fade_to_Black")
			has_clicked = true
		


func _on_bgm_finished() -> void:
	$BGM.play()


func _on_timer_timeout() -> void:
	#Autoloads.main_bgm_seek = $BGM.get_playback_position()
	Autoloads.main_bgm_seek = 0
	get_tree().change_scene_to_file("res://Scenes/tv_scene.tscn")


func _on_start_timeout() -> void:
	show_start()
	can_click = true

func show_start():
	print("called")
	$CanvasLayer/Press.visible = true
	$AnimationPlayer.play("Text")


func _on_ambient_finished() -> void:
	$Ambient.play()
	
