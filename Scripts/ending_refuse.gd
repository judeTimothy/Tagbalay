extends Control


func _on_audio_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
