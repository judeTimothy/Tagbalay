extends Control
@onready var achievement = preload("res://Scenes/achievement.tscn")

func _ready() -> void:
	var b = achievement.instantiate()
	b.achievement = 5
	$UI/CanvasLayer/Color.add_child(b)


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
