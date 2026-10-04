extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("death")

func cat_call():
	$VoiceLine.play()

func stab_ending():
	get_tree().change_scene_to_file("res://Scenes/knife_end.tscn")
