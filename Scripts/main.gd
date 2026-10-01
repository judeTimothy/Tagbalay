extends Node2D

@onready var hover_sfx = preload("res://Assets/Sounds/Menu_Hover_Selection.ogg")
@onready var select_sfx = preload("res://Assets/Sounds/Menu_Click_Selection.ogg")
@onready var next_sfx = preload("res://Assets/Sounds/Game_Next Scene_Click_Selection.ogg")
@onready var slam_sfx = preload("res://Assets/Sounds/Door_Slam.ogg")

const VISITOR_DATA_PATH = "res://Data/visitors.json"

# DEBUG
const DEBUG := true

func _dbg(msg: String) -> void:
	if DEBUG:
		print("[Encounter] ", msg)

var dialogue_index = 0
var visitor: Dictionary      

var lines_positive: Array
var lines_negative: Array


var current_track = "positive"
var slam_unlocked = false


func _ready() -> void:
	_dbg("_ready() start")
	$UI/CanvasLayer/ColorRect.color = Color.BLACK
	$AnimationPlayer.play("Black_to_View")
	$BGM.seek(Autoloads.current_bgm_seek)
	$UI/CanvasLayer/StatusBar/Day.text = "NIGHT " + str(Autoloads.day)

	_load_visitor()
	_apply_visitor_setup()

	$UI/CanvasLayer/StatusBar/DebtLabel.visible = Autoloads.stats_revealed
	_refresh_stat_labels()

	_dbg("_ready() calling set_dialogue(0)")
	set_dialogue(0)
	
	if Autoloads.current_visitor_id == "ugly_beggar_day3":
		$Ambient.play()


func _refresh_stat_labels() -> void:
	$UI/CanvasLayer/StatusBar/Money.text = "P" + str(float(Autoloads.money))
	$UI/CanvasLayer/StatusBar/DebtLabel/TotalDebt.text = "P" + str(float(Autoloads.total_debt))
	# $UI/Stats/Mother.text = "Mother: " + str(Autoloads.mother)
	# $UI/Stats/Condition.text = "Condition: " + str(Autoloads.condition)
	# $UI/Stats/Meds.text = "Meds: " + str(Autoloads.meds)
	# uncomment / add a line here per stat label as you wire each one up


func _load_visitor() -> void:
	var file = FileAccess.open(VISITOR_DATA_PATH, FileAccess.READ)
	if file == null:
		_dbg("FAILED to open " + VISITOR_DATA_PATH + " -- error code: " + str(FileAccess.get_open_error()))
		return

	var raw_text = file.get_as_text()
	file.close()
	_dbg("Loaded JSON file, length: " + str(raw_text.length()))

	var all_visitors = JSON.parse_string(raw_text)
	if all_visitors == null:
		_dbg("FAILED to parse JSON -- check visitors.json for a syntax error (missing comma, bracket, etc)")
		return
	_dbg("Parsed visitor keys: " + str(all_visitors.keys()))


	var visitor_id = Autoloads.current_visitor_id
	_dbg("Autoloads.current_visitor_id = '" + visitor_id + "'")
	if visitor_id == "" or not all_visitors.has(visitor_id):
		visitor_id = all_visitors.keys()[0]
		_dbg("Falling back to first visitor key: '" + visitor_id + "'")

	visitor = all_visitors[visitor_id]
	_dbg("Active visitor: '" + visitor_id + "' -> " + str(visitor))


	if visitor.has("lines"):
		lines_positive = visitor["lines"]
		lines_negative = visitor["lines"]
	else:
		lines_positive = visitor.get("lines_positive", [])
		lines_negative = visitor.get("lines_negative", [])

	_dbg("lines_positive count: " + str(lines_positive.size()) + ", lines_negative count: " + str(lines_negative.size()))


func _apply_visitor_setup() -> void:
	_dbg("_apply_visitor_setup() start")
	# Dynamic sprite swap per visitor.
	if visitor.has("sprite"):
		_dbg("Loading sprite: " + str(visitor["sprite"]))
		$UI/VisitorSprite.texture = load(visitor["sprite"])

	if visitor.has("bgm") and visitor["bgm"] != "":
		_dbg("Loading bgm: " + str(visitor["bgm"]))
		$BGM.stream = load(visitor["bgm"])
		$BGM.play()


func set_dialogue(index: int) -> void:
	_dbg("set_dialogue(" + str(index) + ") called, current_track=" + current_track)
	dialogue_index = index
	var active_lines: Array = lines_positive if current_track == "positive" else lines_negative
	_dbg("active_lines has " + str(active_lines.size()) + " entries")

	if index < 0 or index >= active_lines.size():
		_dbg("INDEX OUT OF RANGE: " + str(index) + " but active_lines only has " + str(active_lines.size()) + " entries -- stopping here")
		return

	var line: Dictionary = active_lines[index]
	_dbg("line content: " + str(line))

	$UI/Dialogue/Dialogue.text = line.get("text", "")
	$UI/Dialogue/Translation.text = line.get("translation", "")
	
	if $UI/Dialogue/Dialogue.text == "" and $UI/Dialogue/Translation.text == "":
		$UI/Dialogue.visible = false
	else:
		$UI/Dialogue.visible = true
	
	$VoiceLine.stop()
	var voice_path = line.get("voice", "")
	if voice_path != "":
		_dbg("Playing voice line: " + voice_path)
		$VoiceLine.stream = load(voice_path)
		$VoiceLine.play()

	var yes: Dictionary = line.get("yes", {})
	var no: Dictionary = line.get("no", {})
	$UI/VBoxContainer/Choice/Yes/Label.text = yes.get("text", "")
	$UI/VBoxContainer/Choice/Yes/Translation.text = yes.get("translation", "")
	$UI/VBoxContainer/Choice/No/Label.text = no.get("text", "")
	$UI/VBoxContainer/Choice/No/Translation.text = no.get("translation", "")
	
	if $UI/Dialogue/Dialogue.text == "" and $UI/Dialogue/Translation.text == "":
		$UI/DialogueBox.visible = false
	else:
		$UI/DialogueBox.visible = true

	
	if $UI/VBoxContainer/Choice/Yes/Label.text == "" and $UI/VBoxContainer/Choice/Yes/Translation.text == "":
		$UI/VBoxContainer/Choice/Yes.visible = false
	else:
		$UI/VBoxContainer/Choice/Yes.visible = true
	if $UI/VBoxContainer/Choice/No/Label.text == "" and $UI/VBoxContainer/Choice/No/Translation.text == "":
		$UI/VBoxContainer/Choice/No.visible = false
	else:
		$UI/VBoxContainer/Choice/No.visible = true


	var slam_index = visitor.get("slam_index", -1)
	if index == slam_index:
		slam_unlocked = true
	$UI/VBoxContainer/Slam.visible = slam_unlocked


	var reveal_index = visitor.get("reveal_index", -1)
	if not Autoloads.stats_revealed and index == reveal_index:
		Autoloads.stats_revealed = true
		$UI/CanvasLayer/StatusBar/DebtLabel.visible = true
		#$UI/Stats.visible = true
		$Paper.play()


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
	_dbg("YES pressed at dialogue_index=" + str(dialogue_index))
	_on_choice_pressed("yes")

func _on_no_pressed() -> void:
	_dbg("NO pressed at dialogue_index=" + str(dialogue_index))
	_on_choice_pressed("no")

func _on_choice_pressed(choice: String) -> void:
	$VoiceLine.stop()


	var active_lines: Array = lines_positive if current_track == "positive" else lines_negative
	var line: Dictionary = active_lines[dialogue_index]
	var chosen: Dictionary = line.get(choice, {})
	var effect = chosen.get("effect", "")
	if effect != "":
		_dbg("Applying effect: " + effect)
		Autoloads.apply_effect(effect)
		_refresh_stat_labels()

	current_track = "positive" if choice == "yes" else "negative"

	var next_lines: Array = lines_positive if current_track == "positive" else lines_negative
	_dbg("dialogue_index=" + str(dialogue_index) + ", next_lines.size()=" + str(next_lines.size()))

	if dialogue_index < next_lines.size() - 1:
		_dbg("Advancing to index " + str(dialogue_index + 1))
		set_dialogue(dialogue_index + 1)
		$SFX.stream = select_sfx
		$SFX.play()
	else:
		_dbg("No more lines -- ending encounter")
		$SFX.stream = next_sfx
		$SFX.play()
		$AnimationPlayer.play("Fade_to_Black")
		$Timer.start()


func _on_slam_pressed() -> void:
	$VoiceLine.stop()

	var effect = visitor.get("slam_effect", "")
	if effect != "":
		_dbg("Applying slam effect: " + effect)
		Autoloads.apply_effect(effect)

	$SFX.stream = slam_sfx
	$SFX.play()
	$AnimationPlayer.play("Fade_to_Black")
	$Timer.start()


func _on_timer_timeout() -> void:
	Autoloads.current_bgm_seek = $BGM.get_playback_position()
	Autoloads.day_visitor_index += 1
	Autoloads.after_encounter = true
	Autoloads.from_intro = false
	get_tree().change_scene_to_file("res://Scenes/DoorScene.tscn")


func _on_ambient_finished() -> void:
	$Ambient.play()
