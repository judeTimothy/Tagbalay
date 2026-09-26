extends Node2D
@onready var creepy_bgm = preload("res://Assets/Music/(4) Creepy Ambience.ogg")
@onready var hover_sfx = preload("res://Assets/Sounds/Menu_Hover_Selection.ogg")
@onready var select_sfx = preload("res://Assets/Sounds/Menu_Click_Selection.ogg")
@onready var next_sfx = preload("res://Assets/Sounds/Game_Next Scene_Click_Selection.ogg")
@onready var slam_sfx = preload("res://Assets/Sounds/Door_Slam.ogg")

var dialogue_index = 0
var chosen = 0
var dialogue_array = 	["Mayong gab-e, to. Pasensya gd sa distorbo. Amo ni ang balay ni Carmen?",
						"Carmen Isidro.",
						"Tinawo ko gali ni Boss Pedro. May utang di si Carmen Isidro sang P69,420.67. Lapit na isa ka bulan nga wala siya kabayad.",
						"Seryoso ni bala to kag kadako gid sang utang nyo. Kung nde maka pakita si mama mo, ikaw atubang sang iya utang. Mabalik kami bwas. Indi pag hulta si boss mismo ang makadto sa inyo."]
var translation_array = ["(Good evening, young man. Sorry for the late notice, but is this the residence of Carmen?)",
						"(Carmen Isidro.)",
						"(I was tasked by Boss Pedro. It says here that Carmen Isidro owes us P69,420.67, and she missed a month's worth of payment.)",
						"(This is a serious matter, young man. And it is a hefty sum. If your mother is unavailable, you deal with it. We'll return tomorrow. Don't make this complicated. You don't want the Boss to visit you himself.)"]

var yes_array = ["Mayong gab-e man.", "Oo, mama ko sya.", "Gamasakit sya nong.", "..."]
var yes_translation = ["(Good evening to you, too.)", "(Yes, she's my mother.)", "(She's sick.)", "(Stay silent.)"]
var no_array = ["...", "Indi ko na sa kilala.", "Basi sa piyak balay sa nong.","..."]
var no_translation = ["(Stay silent.)", "(I don't know her.)", "(She probably lives at that other house.)", "(Stay silent.)"]

func _ready() -> void:
	$UI/CanvasLayer/ColorRect.color = Color.BLACK
	$AnimationPlayer.play("Black_to_View")
	$BGM.seek(Autoloads.current_bgm_seek)
	if Autoloads.day == 1:
		$UI/Stats.visible = false
	else:
		$UI/Stats.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$UI/Dialogue/Dialogue.text = dialogue_array[dialogue_index]
	$UI/Dialogue/Translation.text = translation_array[dialogue_index]
	$UI/VBoxContainer/Choice/Yes/Label.text = yes_array[dialogue_index]
	$UI/VBoxContainer/Choice/Yes/Translation.text = yes_translation[dialogue_index]
	$UI/VBoxContainer/Choice/No/Label.text = no_array[dialogue_index]
	$UI/VBoxContainer/Choice/No/Translation.text = no_translation[dialogue_index]
	
	if Autoloads.day != 1 and dialogue_index == 2:
		$UI/VBoxContainer/Slam.visible = true
	else:
		$UI/VBoxContainer/Slam.visible = false
			


func _on_yes_mouse_entered() -> void:
	$UI/VBoxContainer/Choice/Yes/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_yes_mouse_exited() -> void:
	$UI/VBoxContainer/Choice/Yes/Label.remove_theme_color_override("font_color")


func _on_no_mouse_entered() -> void:
	$UI/VBoxContainer/Choice/No/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_no_mouse_exited() -> void:
	$UI/VBoxContainer/Choice/No/Label.remove_theme_color_override("font_color")
	
	
func _on_slam_mouse_entered() -> void:
	$UI/VBoxContainer/Slam/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_slam_mouse_exited() -> void:
	$UI/VBoxContainer/Slam/Label.remove_theme_color_override("font_color")
	
	
func _on_bgm_finished() -> void:
	$BGM.play()


func _on_yes_pressed() -> void:
	if Autoloads.day == 1:
		if dialogue_index == 2:
			$UI/Stats.visible = true
			$Paper.play()
	if dialogue_index < 3:
		dialogue_index += 1
		$SFX.stream = select_sfx
		$SFX.play()
	else:
		$SFX.stream = next_sfx
		$SFX.play()
		$AnimationPlayer.play("Fade_to_Black")
		$Timer.start()

func _on_no_pressed() -> void:
	if Autoloads.day == 1:
		if dialogue_index == 2:
			$UI/Stats.visible = true
			$Paper.play()
	if dialogue_index < 3:
		dialogue_index += 1
		$SFX.stream = select_sfx
		$SFX.play()
	else:
		$SFX.stream = next_sfx
		$SFX.play()
		$AnimationPlayer.play("Fade_to_Black")
		$Timer.start()
		
		
func _on_slam_pressed() -> void:
	$SFX.stream = slam_sfx
	$SFX.play()
	$AnimationPlayer.play("Fade_to_Black")
	$Timer.start()


func _on_timer_timeout() -> void:
	Autoloads.current_bgm_seek = $BGM.get_playback_position()
	Autoloads.visitor_count -= 1
	Autoloads.after_encounter = true
	Autoloads.from_intro = false
	get_tree().change_scene_to_file("res://Scenes/DoorScene.tscn")
