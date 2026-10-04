extends Control
@onready var knock_sfx = preload("res://Assets/Sounds/Knock.ogg")


var subtitle_entries := [
	{"time": 0.0, "text": "Maayong gab-e", "translation": "(Good evening.)"},
	{"time": 1.0, "text": "Sa aton pinakabag-o nga mga balita.", "translation": "(On our latest news,)"},
	{"time": 3.3, "text": "padayon gihapon ang ginabantayan sang publiko nga pagdinig", "translation": "(we continue to closely watch a public hearing)"},
	{"time": 6.9, "text": "tuhoy sa isa ka kontrobersyal nga kaso sa nasyonal nga gobyerno.", "translation": "(about an infamous national controversy.)"},
	{"time": 11.10, "text": "Suno sa mga opisyal,", "translation": "(According to the officials,)"},
	{"time": 12.5, "text": "magapadayon ang mga pagdinig sa masunod nga mga adlaw", "translation": "(the hearing will continue in the following days)"},
	{"time": 15.9, "text": "samtang gina presentar sang tagsa ka panig", "translation": "(as both sides present)"},
	{"time": 18.2, "text": "ang ila mga ebidensya kag sabat sa mga pamangkot.", "translation": "(evidence and respond to the questions.)"},
	{"time": 21.9, "text": "Sa karon,", "translation": "(For now,)"},
	{"time": 22.7, "text": "wala pa sang kasiguraduhan kung san-o matapos ang proseso.", "translation": "(there is no clear indication of when the proceedings will conclude.)"},
	{"time": 26.47, "text": "Ginapangabay naman sa publiko nga maghulat kag magsalig", "translation": "(Authorities are urging the public to remain confident and patient)"}, 
	{"time": 29.5, "text": "sa nagapadayon nga pamaagi sang hustisya", "translation": "(as the process moves forward.)"},
	{"time": 32.73, "text": "Samtang, nagapadayon ang adlaw-adlaw nga kabuhi", "translation": "(Meanwhile, life continues as normal)"},
	{"time": 35.9, "text": "sang mga pumuluyo sa bilog nga pungsod.", "translation": "(across the nation.)"},
	{"time": 38.5, "text": "Amo ina ang aton pinakabag-o nga balita.", "translation": "(And that is the latest for now.)"},
	{"time": 41.33, "text": "Magapadayon kami sa pag monitor sa mga nagatabo", "translation": "(We will continue to monitor developments as they unfold.)"},
	{"time": 44.71, "text": "Maayong gab-i, kag salamat sa inyo pagpamati.", "translation": "(Good evening and thank you for listening.)"},
]

var subtitle_index := 0
var last_playback_pos := 0.0

var can_click = false
var has_clicked = false

func _ready() -> void:
	$AnimationPlayer.play("Black_to_View")


func _process(delta: float) -> void:
	if Input.is_action_pressed("click"):
		if can_click == true and has_clicked == false:
			$Timer.start()
			$CanvasLayer/Check.visible = false
			$AnimationPlayer.play("Fade_to_Black")
			has_clicked = true
	
	if not $Newscast.playing:
		return

	var pos: float = $Newscast.get_playback_position()

	if pos < last_playback_pos - 0.1:
		subtitle_index = 0
	last_playback_pos = pos

	while subtitle_index < subtitle_entries.size() - 1 and pos >= subtitle_entries[subtitle_index + 1]["time"]:
		subtitle_index += 1

	var entry: Dictionary = subtitle_entries[subtitle_index]
	$CanvasLayer/Subtitles.text = entry.get("text", "")
	$CanvasLayer/SubtitleTranslation.text = entry.get("translation", "")


func _on_knock_countdown_timeout() -> void:
	$SFX.stream = knock_sfx
	can_click = true
	$CanvasLayer/Check.visible = true
	$AnimationPlayer.play("Text")
	$SFX.play()


func _on_sfx_finished() -> void:
	$SFX.play()


func _on_newscast_finished() -> void:
	$Newscast.play()


func _on_ambient_finished() -> void:
	$Ambient.play()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/DoorScene.tscn")
