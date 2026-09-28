extends Node2D

# ---------------------------------------------------------
# Visitor data is now external (res://Data/visitors.json).
# Non-technical people can edit that file in any text editor
# or Google Sheets -> export as JSON, no Godot knowledge needed.
# ---------------------------------------------------------

@onready var hover_sfx = preload("res://Assets/Sounds/Menu_Hover_Selection.ogg")
@onready var select_sfx = preload("res://Assets/Sounds/Menu_Click_Selection.ogg")
@onready var next_sfx = preload("res://Assets/Sounds/Game_Next Scene_Click_Selection.ogg")
@onready var slam_sfx = preload("res://Assets/Sounds/Door_Slam.ogg")

const VISITOR_DATA_PATH = "res://Data/visitors.json"

# --- DEBUG ---------------------------------------------------
# Flip to false (or delete this line + every _dbg(...) call below)
# to remove debug output. Every debug line is tagged "[Encounter]"
# so you can also just search-and-delete by that tag.
const DEBUG := true

func _dbg(msg: String) -> void:
	if DEBUG:
		print("[Encounter] ", msg)
# ---------------------------------------------------------------

var dialogue_index = 0
var visitor: Dictionary       # the one visitor entry we're running

# Two parallel scripts. For a visitor that doesn't branch (day 1), both
# just point at the same array, so nothing downstream needs to know or
# care whether this visitor is "single track" or "two track."
var lines_positive: Array
var lines_negative: Array

# Which track we're currently reading from. Flips to match whichever
# button was last pressed; index 0 is identical in both tracks so the
# starting value here never matters.
var current_track: String = "positive"

# Once Slam appears, it stays -- this is a one-way flag, not tied to
# the current index, so it survives past the line that first shows it.
var slam_unlocked: bool = false


func _ready() -> void:
	_dbg("_ready() start")
	$UI/CanvasLayer/ColorRect.color = Color.BLACK
	$AnimationPlayer.play("Black_to_View")
	$BGM.seek(Autoloads.current_bgm_seek)
	$UI/CanvasLayer/StatusBar/Day.text = "NIGHT " + str(Autoloads.day)

	_load_visitor()
	_apply_visitor_setup()

	# Stats reveal is a one-time flip stored on Autoloads, not tied to
	# "is it day 1" — once revealed it stays visible on every later day.
	#$UI/Stats.visible = Autoloads.stats_revealed
	$UI/CanvasLayer/StatusBar/DebtLabel.visible = Autoloads.stats_revealed
	_refresh_stat_labels()

	_dbg("_ready() calling set_dialogue(0)")
	set_dialogue(0)


# Repaints every visible stat label straight from Autoloads. Called after
# any effect, rather than trying to figure out which specific stat an
# effect touched -- one place to extend as more stat labels get added.
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

	# Autoloads.current_visitor_id is set by whatever picks the day's
	# visitor (DoorScene, a day/visitor table, etc). Falls back to the
	# first key if unset, so this doesn't hard-crash during testing.
	var visitor_id = Autoloads.current_visitor_id
	_dbg("Autoloads.current_visitor_id = '" + visitor_id + "'")
	if visitor_id == "" or not all_visitors.has(visitor_id):
		visitor_id = all_visitors.keys()[0]
		_dbg("Falling back to first visitor key: '" + visitor_id + "'")

	visitor = all_visitors[visitor_id]
	_dbg("Active visitor: '" + visitor_id + "' -> " + str(visitor))

	# "lines" = single-track shorthand (day 1 style prototyping).
	# "lines_positive" / "lines_negative" = branching visitors.
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

	# Optional per-visitor BGM override; falls back to whatever is
	# already assigned to $BGM in the scene.
	if visitor.has("bgm") and visitor["bgm"] != "":
		_dbg("Loading bgm: " + str(visitor["bgm"]))
		$BGM.stream = load(visitor["bgm"])
		$BGM.play()


# ---------------------------------------------------------
# Single source of truth for "what does the screen show right now".
# Called on index change only -- not every _process() frame.
# ---------------------------------------------------------
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

	# Voice line for this dialogue line, if any. Stop whatever was
	# playing first -- otherwise a line with no "voice" would just let
	# the previous line's clip keep running underneath the new text.
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

	# slam_index: which line the "slam the door" option first appears on.
	# -1 (or absent) means this visitor never offers it. Once unlocked
	# it stays visible for the rest of the encounter, even as the
	# player moves past that line.
	var slam_index = visitor.get("slam_index", -1)
	if index == slam_index:
		slam_unlocked = true
	$UI/VBoxContainer/Slam.visible = slam_unlocked

	# reveal_index: which line flips the stats UI on, permanently.
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


# Yes/No now share one path. Whether a choice "matters" is entirely
# data-driven: if this line's yes/no dict has a non-empty "effect",
# it gets forwarded to Autoloads; visitors that don't care just leave
# "effect" out (or "") and nothing happens.
func _on_yes_pressed() -> void:
	_dbg("YES pressed at dialogue_index=" + str(dialogue_index))
	_on_choice_pressed("yes")

func _on_no_pressed() -> void:
	_dbg("NO pressed at dialogue_index=" + str(dialogue_index))
	_on_choice_pressed("no")

func _on_choice_pressed(choice: String) -> void:
	$VoiceLine.stop()

	# Read the effect off the line as currently displayed, BEFORE
	# switching tracks -- this is still "what the player just chose."
	var active_lines: Array = lines_positive if current_track == "positive" else lines_negative
	var line: Dictionary = active_lines[dialogue_index]
	var chosen: Dictionary = line.get(choice, {})
	var effect = chosen.get("effect", "")
	if effect != "":
		_dbg("Applying effect: " + effect)
		Autoloads.apply_effect(effect)
		_refresh_stat_labels()

	# From here on, follow whichever track this choice belongs to.
	# "yes" == positive, "no" == negative. For single-track visitors
	# this is a no-op since both arrays are the same reference.
	current_track = "positive" if choice == "yes" else "negative"

	# Check against whichever track we just switched to -- not a fixed
	# array or a magic number -- so tracks of different lengths (or a
	# writer's typo in the JSON) can't run past the end of an array.
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
