extends Node2D
@onready var achievement = preload("res://Scenes/achievement.tscn")

func _ready() -> void:
	$AnimationPlayer.play("death")
	var b = achievement.instantiate()
	b.achievement = 1
	$UI/CanvasLayer/CRT.add_child(b)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
