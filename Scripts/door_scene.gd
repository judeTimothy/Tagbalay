extends Node2D
@onready var creepy_bgm = preload("res://Assets/Music/(4) Creepy Ambience.ogg")
@onready var hover_sfx = preload("res://Assets/Sounds/Menu_Hover_Selection.ogg")
@onready var select_sfx = preload("res://Assets/Sounds/Menu_Click_Selection.ogg")
@onready var next_sfx = preload("res://Assets/Sounds/Game_Next Scene_Click_Selection.ogg")
@onready var knock_sfx = preload("res://Assets/Sounds/Knock.ogg")
@onready var toast = preload("res://Scenes/toast.tscn")


var meds = 0
var money = 500
var mother = 20
var condition = 20
var day = 1
var night = false
var knocking = false
var given_medicine = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$UI/CanvasLayer/Color.color = Color8(1,1,1,0)
	day = Autoloads.day
	if day == 1:
		$UI/Stats.visible = false
	else:
		$UI/Stats.visible = true
	if Autoloads.after_encounter == true:
		night = true
		Autoloads.after_encounter = false
	#Autoloads.visitor_count = Autoloads.visitor_array[day]
	print(Autoloads.visitor_count)
	
	if Autoloads.from_intro == true:
		$BGM.seek(Autoloads.current_bgm_seek)
		$AnimationPlayer.play("Black_to_View_Intro")
	else:
		$BGM.seek(Autoloads.current_bgm_seek)
		$AnimationPlayer.play("Black_to_View")
	if day > 1:
		if night == true:
			find_visitor()
	else:
		night = true
		if Autoloads.visitor_count > 0:
			$Knock.stream = knock_sfx
			knocking = true
			$Knock.play()
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if night == false:
		$UI/DayActions.visible = true
		$TextureRect.modulate = Color.from_rgba8(188,135,113,255)
		$Door.disabled = true
	else:
		$UI/DayActions.visible = false
		$TextureRect.modulate = Color.from_rgba8(91,71,207,255)
		$Door.disabled = false
	
	if money >= 40:
		$UI/DayActions/Buy.disabled = false
	else:
		$UI/DayActions/Buy.disabled = true
		
	if meds >= 1:
		$UI/DayActions/Meds.disabled = false
	else:
		$UI/DayActions/Meds.disabled = true
	
	if Autoloads.visitor_count == 0:
		$UI/CanvasLayer/NoMore.visible = true
		$UI/CanvasLayer/Sleep.visible = true
		$Door.disabled = true
		knocking = false
	else:
		$UI/CanvasLayer/NoMore.visible = false
		if knocking == true:
			$Door.disabled = false
		else:
			$Door.disabled = true
		$UI/CanvasLayer/Sleep.visible = false
	


func _on_work_mouse_entered() -> void:
	$UI/DayActions/Work/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_work_mouse_exited() -> void:
	$UI/DayActions/Work/Label.remove_theme_color_override("font_color")


func _on_rest_mouse_entered() -> void:
	$UI/DayActions/Rest/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_rest_mouse_exited() -> void:
	$UI/DayActions/Rest/Label.remove_theme_color_override("font_color")


func _on_care_mouse_entered() -> void:
	$UI/DayActions/Care/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_care_mouse_exited() -> void:
	$UI/DayActions/Care/Label.remove_theme_color_override("font_color")
	

func _on_meds_mouse_entered() -> void:
	if $UI/DayActions/Meds.disabled == false:
		$UI/DayActions/Meds/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
		$SFX.stream = hover_sfx
		$SFX.play()


func _on_meds_mouse_exited() -> void:
	$UI/DayActions/Meds/Label.remove_theme_color_override("font_color")
	
		
func _on_buy_mouse_entered() -> void:
	if $UI/DayActions/Buy.disabled == false:
		$UI/DayActions/Buy/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
		$SFX.stream = hover_sfx
		$SFX.play()

func _on_buy_mouse_exited() -> void:
	$UI/DayActions/Buy/Label.remove_theme_color_override("font_color")
	
	
func _on_sleep_mouse_entered() -> void:
	$UI/CanvasLayer/Sleep/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_sleep_mouse_exited() -> void:
	$UI/CanvasLayer/Sleep/Label.remove_theme_color_override("font_color")

func _on_work_pressed() -> void:
	$SFX.stream = select_sfx
	$SFX.play()
	$AnimationPlayer.play("Fade_to_Black")
	$Timer.start()

func _on_rest_pressed() -> void:
	$SFX.stream = select_sfx
	$SFX.play()
	if condition <= 75:
		condition += 25
	else:
		condition = 100
	$AnimationPlayer.play("Fade_to_Black")
	$Timer.start()
	

func _on_care_pressed() -> void:
	$SFX.stream = select_sfx
	$SFX.play()
	if mother <= 74:
		$UI/DayActions/Meds.visible = true
		$UI/DayActions/Buy.visible = true
		if mother <= 74 and mother >= 50:
			var t = toast.instantiate()
			t.display_text("Mother is in a worse state.")
			t.global_position = $UI/CanvasLayer/Point.global_position/4
			$UI/CanvasLayer/Point.add_child(t)
		elif mother <= 49 and mother >= 25:
			var t = toast.instantiate()
			t.display_text("Mother is in horrible condition.")
			t.global_position = $UI/CanvasLayer/Point.global_position/4
			$UI/CanvasLayer/Point.add_child(t)
		elif mother <= 24:
			var t = toast.instantiate()
			t.display_text("Mother is in critical condition.")
			t.global_position = $UI/CanvasLayer/Point.global_position/4
			$UI/CanvasLayer/Point.add_child(t)
	else:
		$UI/DayActions/Meds.visible = false
		$UI/DayActions/Buy.visible = false
		var t = toast.instantiate()
		t.display_text("Mother is in stable condition.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)

func _on_buy_pressed() -> void:
	if money >= 40:
		money -= 40
		meds += 1
		var t = toast.instantiate()
		t.display_text("You've bought medicine.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)
	else:
		$UI/DayActions/Buy/Label.remove_theme_color_override("font_color")
	$SFX.stream = select_sfx
	$SFX.play()

func _on_meds_pressed() -> void:
	if given_medicine == false:
		meds -= 1
		mother += 10
		var t = toast.instantiate()
		t.display_text("Mother took her meds. She's recovering.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)
	else:
		var t = toast.instantiate()
		t.display_text("Mother already took her meds.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)
	$SFX.stream = select_sfx
	$SFX.play()
	given_medicine = true
	if meds == 0:
		$UI/DayActions/Meds/Label.remove_theme_color_override("font_color")


func _on_door_pressed() -> void:
	$SFX.stream = next_sfx
	$SFX.play()
	$Knock.stop()
	$AnimationPlayer.play("Fade_to_Black")
	$SceneChange.start()
	knocking = false

func _on_scene_change_timeout() -> void:
	Autoloads.current_bgm_seek = $BGM.get_playback_position()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_timer_timeout() -> void:
	$SFX.stream = next_sfx
	$SFX.play()
	night = true
	$AnimationPlayer.play("Black_to_View")
	find_visitor()


func _on_sleep_pressed() -> void:
	$SFX.stream = select_sfx
	$SFX.play()
	$AnimationPlayer.play("Fade_to_Black")
	$TimerMorn.start()
	Autoloads.day += 1
	Autoloads.visitor_count = Autoloads.visitor_array[Autoloads.day]


func _on_timer_morn_timeout() -> void:
	$SFX.stream = next_sfx
	$SFX.play()
	get_tree().reload_current_scene()


func _on_knock_countdown_timeout() -> void:
	$Knock.stream = knock_sfx
	$Knock.play()
	knocking = true


func _on_knock_finished() -> void:
	$Knock.play()

func find_visitor():
	var rng = RandomNumberGenerator.new()
	randomize()
	var rand = rng.randf_range(3,5)
	$KnockCountdown.wait_time = rand
	$KnockCountdown.start()
