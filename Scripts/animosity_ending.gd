extends Node2D
@onready var achievement = preload("res://Scenes/achievement.tscn")

func _ready() -> void:
	$AnimationPlayer.play("death")
	var b = achievement.instantiate()
	b.achievement = 6
	$UI/CanvasLayer/CRT.add_child(b)
	
func cat_call():
	$VoiceLine.play()

func stab_ending():
	get_tree().change_scene_to_file("res://Scenes/knife_end.tscn")
