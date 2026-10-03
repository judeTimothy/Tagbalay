extends Node2D
@onready var creepy_bgm = preload("res://Assets/Music/(4) Creepy Ambience.ogg")
@onready var hover_sfx = preload("res://Assets/Sounds/Menu_Hover_Selection.ogg")
@onready var select_sfx = preload("res://Assets/Sounds/Menu_Click_Selection.ogg")
@onready var next_sfx = preload("res://Assets/Sounds/Game_Next Scene_Click_Selection.ogg")
@onready var knock_sfx = preload("res://Assets/Sounds/Knock.ogg")
@onready var aggressive_sfx = preload("res://Assets/Sounds/Knock_Aggressive3.ogg")
@onready var toast = preload("res://Scenes/toast.tscn")

# manual changing of texture over CRt
@onready var normal_texture = preload("res://Assets/UI/button_new.png")
@onready var pressed_texture = preload("res://Assets/UI/button_hover.png")

var day = 1
var night = false
var knocking = false
var given_medicine = false
var taken_care = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_mother_status()
	
	print("Day ", Autoloads.day, " start.")
	if Autoloads.flags.get("shady_man_sheltered", false):
		get_tree().change_scene_to_file("res://Scenes/knife_end.tscn")
	#print(Autoloads.flags)
	#$UI/CanvasLayer/Color.color = Color8(1,1,1,0)
	#Autoloads.build_today_pool()
	$UI/CanvasLayer/StatusBar/Money.text = "P" + str(float(Autoloads.money))
	$UI/CanvasLayer/StatusBar/DebtLabel/TotalDebt.text = "P" + str(float(Autoloads.total_debt))
	day = Autoloads.day
	if day == 1:
		if night == false:
			$UI/CanvasLayer/StatusBar/DebtLabel.visible = false
			#$UI/Stats.visible = false
		else:
			$UI/CanvasLayer/StatusBar/DebtLabel.visible = true
	else:
		#$UI/Stats.visible = true
		$UI/CanvasLayer/StatusBar/DebtLabel.visible = true
	if Autoloads.after_encounter == true:
		if day == 1:
			$UI/CanvasLayer/StatusBar/DebtLabel.visible = true
		night = true
		Autoloads.after_encounter = false
	
	
	print(Autoloads.visitors_remaining_today())
	print(Autoloads.current_visitor_id)

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
		if Autoloads.visitors_remaining_today() > 0:
			$Knock.stream = knock_sfx
			knocking = true
			$Knock.play()
	var buffer = ""
	print(night)
	if night:
		buffer = "NIGHT "
	else:
		buffer = "DAY "
	$UI/CanvasLayer/StatusBar/Day.text = buffer + str(Autoloads.day)
	
	if (Autoloads.current_visitor_id == "ugly_beggar_day6" or Autoloads.current_visitor_id == "ugly_beggar_day8" or Autoloads.current_visitor_id == "ugly_beggar_day3" or Autoloads.current_visitor_id == "empty_day5" or Autoloads.current_visitor_id == "sinister_male_day5" or Autoloads.current_visitor_id == "collector_young_day3" or Autoloads.current_visitor_id == "sinister_male_day6" or Autoloads.current_visitor_id == "collector_young_day8") and night:
		$Ambient.play()
		var t = toast.instantiate()
		t.display_text("It's raining outside.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)
	else:
		$Ambient.stop()
		
	
	
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
	
	$UI/CanvasLayer/Hearts/MotherCondition.value = Autoloads.mother
	$UI/CanvasLayer/Hearts/Condition.value = Autoloads.condition
	
	if Autoloads.money >= 40:
		$UI/DayActions/Buy.disabled = false
	else:
		$UI/DayActions/Buy.disabled = true
		
	if Autoloads.meds >= 1:
		$UI/DayActions/Meds.disabled = false
	else:
		$UI/DayActions/Meds.disabled = true
	
	if Autoloads.visitors_remaining_today() == 0:
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
	$UI/DayActions/Work.texture_normal = pressed_texture
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_work_mouse_exited() -> void:
	$UI/DayActions/Work/Label.remove_theme_color_override("font_color")
	$UI/DayActions/Work.texture_normal = normal_texture


func _on_rest_mouse_entered() -> void:
	$UI/DayActions/Rest/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$UI/DayActions/Rest.texture_normal = pressed_texture
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_rest_mouse_exited() -> void:
	$UI/DayActions/Rest/Label.remove_theme_color_override("font_color")
	$UI/DayActions/Rest.texture_normal = normal_texture


func _on_care_mouse_entered() -> void:
	$UI/DayActions/Care/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$UI/DayActions/Care.texture_normal = pressed_texture
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_care_mouse_exited() -> void:
	$UI/DayActions/Care/Label.remove_theme_color_override("font_color")
	$UI/DayActions/Care.texture_normal = normal_texture
	

func _on_meds_mouse_entered() -> void:
	if $UI/DayActions/Meds.disabled == false:
		$UI/DayActions/Meds/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
		$UI/DayActions/Meds.texture_normal = pressed_texture
		$SFX.stream = hover_sfx
		$SFX.play()


func _on_meds_mouse_exited() -> void:
	$UI/DayActions/Meds/Label.remove_theme_color_override("font_color")
	$UI/DayActions/Meds.texture_normal = normal_texture
	
		
func _on_buy_mouse_entered() -> void:
	if $UI/DayActions/Buy.disabled == false:
		$UI/DayActions/Buy/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
		$UI/DayActions/Buy.texture_normal = pressed_texture
		$SFX.stream = hover_sfx
		$SFX.play()

func _on_buy_mouse_exited() -> void:
	$UI/DayActions/Buy/Label.remove_theme_color_override("font_color")
	$UI/DayActions/Buy.texture_normal = normal_texture
	
	
func _on_sleep_mouse_entered() -> void:
	$UI/CanvasLayer/Sleep/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$UI/CanvasLayer/Sleep.texture_normal = pressed_texture
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_sleep_mouse_exited() -> void:
	$UI/CanvasLayer/Sleep/Label.remove_theme_color_override("font_color")
	$UI/CanvasLayer/Sleep.texture_normal = normal_texture

func _on_take_care_mouse_entered() -> void:
	$UI/DayActions/TakeCare/Label.add_theme_color_override("font_color", Color.from_rgba8(1,1,1,255))
	$UI/DayActions/TakeCare.texture_normal = pressed_texture
	$SFX.stream = hover_sfx
	$SFX.play()

func _on_take_care_mouse_exited() -> void:
	$UI/DayActions/TakeCare/Label.remove_theme_color_override("font_color")
	$UI/DayActions/TakeCare.texture_normal = normal_texture


func _on_work_pressed() -> void:
	$SFX.stream = select_sfx
	$SFX.play()
	$AnimationPlayer.play("Fade_to_Black")
	$Timer.start()
	Autoloads.apply_effect("money(550)")
	Autoloads.apply_effect("condition(-10)")
	
func _on_rest_pressed() -> void:
	$SFX.stream = select_sfx
	$SFX.play()
	
	Autoloads.apply_effect("condition(5)")
	$AnimationPlayer.play("Fade_to_Black")
	$Timer.start()
	

func _on_care_pressed() -> void:
	$SFX.stream = select_sfx
	$SFX.play()
	$UI/DayActions/Meds/Label.text = "Give Meds(" + str(Autoloads.meds) + ")"
	if Autoloads.mother <= 30:
		$UI/DayActions/Meds.visible = true
		$UI/DayActions/Buy.visible = true
		$UI/DayActions/TakeCare.visible = true
		$UI/CanvasLayer/DayActions/Meds.visible = true
		$UI/CanvasLayer/DayActions/Buy.visible = true
		$UI/CanvasLayer/DayActions/TakeCare.visible = true

		if Autoloads.mother >= 25:
			var t = toast.instantiate()
			t.display_text("Mother is in a worse state.")
			t.global_position = $UI/CanvasLayer/Point.global_position / 4
			$UI/CanvasLayer/Point.add_child(t)

		elif Autoloads.mother >= 15:
			var t = toast.instantiate()
			t.display_text("Mother is in horrible condition.")
			t.global_position = $UI/CanvasLayer/Point.global_position / 4
			$UI/CanvasLayer/Point.add_child(t)

		else:
			var t = toast.instantiate()
			t.display_text("Mother is in critical condition.")
			t.global_position = $UI/CanvasLayer/Point.global_position / 4
			$UI/CanvasLayer/Point.add_child(t)

	else:
		$UI/DayActions/Meds.visible = false
		$UI/DayActions/Buy.visible = false
		$UI/DayActions/TakeCare.visible = false
		$UI/CanvasLayer/DayActions/Meds.visible = false
		$UI/CanvasLayer/DayActions/Buy.visible = false
		$UI/CanvasLayer/DayActions/TakeCare.visible = false
		var t = toast.instantiate()
		t.display_text("Mother is in stable condition.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)

func _on_take_care_pressed() -> void:
	if taken_care == false:
		Autoloads.apply_effect("mother(5)")
		Autoloads.apply_effect("condition(-10)")
		var t = toast.instantiate()
		t.display_text("You took care of Mother.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)
	else:
		var t = toast.instantiate()
		t.display_text("You already took care of Mother.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)
	$SFX.stream = select_sfx
	$SFX.play()
	taken_care = true

func _on_buy_pressed() -> void:
	if Autoloads.money >= 40:
		Autoloads.apply_effect("money(-40)")
		Autoloads.apply_effect("meds(1)")
		var t = toast.instantiate()
		t.display_text("You've bought medicine.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)
	else:
		$UI/DayActions/Buy/Label.remove_theme_color_override("font_color")
	$SFX.stream = select_sfx
	$SFX.play()
	$UI/CanvasLayer/StatusBar/Money.text = "Cash: P" + str(float(Autoloads.money))
	$UI/DayActions/Meds/Label.text = "Give Meds(" + str(Autoloads.meds) + ")"

func _on_meds_pressed() -> void:
	if given_medicine == false:
		Autoloads.apply_effect("mother(10)")
		Autoloads.apply_effect("meds(-1)")
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
	if Autoloads.meds == 0:
		$UI/DayActions/Meds/Label.remove_theme_color_override("font_color")
	$UI/DayActions/Meds/Label.text = "Give Meds(" + str(Autoloads.meds) + ")"


func _on_door_pressed() -> void:
	$SFX.stream = next_sfx
	$SFX.play()
	$Knock.stop()
	Autoloads.pick_visitor_for_today()
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
	check_player_status()
	find_visitor()
	$UI/CanvasLayer/StatusBar/Day.text = "NIGHT " + str(Autoloads.day)
	$UI/CanvasLayer/StatusBar/Money.text = "P" + str(float(Autoloads.money))
	
	if Autoloads.day == 10:
		$Ambient.play()
		var t = toast.instantiate()
		t.display_text("It's raining outside.")
		t.global_position = $UI/CanvasLayer/Point.global_position/4
		$UI/CanvasLayer/Point.add_child(t)


func _on_sleep_pressed() -> void:
	$SFX.stream = select_sfx
	$SFX.play()
	$AnimationPlayer.play("Fade_to_Black")
	$TimerMorn.start()
	Autoloads.advance_to_next_day()
	
	


func _on_timer_morn_timeout() -> void:
	$SFX.stream = next_sfx
	$SFX.play()
	if Autoloads.day == 1 or Autoloads.day == 2 or Autoloads.day == 3:
		Autoloads.apply_effect("mother(-5)")
	elif Autoloads.day == 4 or Autoloads.day == 5 or Autoloads.day == 6:
		Autoloads.apply_effect("mother(-10)")
	elif Autoloads.day == 7 or Autoloads.day == 8 or Autoloads.day == 9 or Autoloads.day == 10:
		Autoloads.apply_effect("mother(-15)")
	else:
		Autoloads.apply_effect("mother(-10)")
	Autoloads.apply_effect("condition(10)")
	get_tree().reload_current_scene()


func _on_knock_countdown_timeout() -> void:
	if Autoloads.day == 10:
		$Boss.play()
		knocking = true
	else:
		if Autoloads.visitors_remaining_today() > 0:
			if Autoloads.current_visitor_id == "chismosa_day9":
				$Knock.stream = aggressive_sfx
			else:
				$Knock.stream = knock_sfx
			$Knock.play()
			knocking = true


func _on_knock_finished() -> void:
	$Knock.play()

func find_visitor():
	var rng = RandomNumberGenerator.new()
	randomize()
	var rand = rng.randf_range(3,5)
	randomize()
	randomize()
	$KnockCountdown.wait_time = rand
	if Autoloads.day == 10:
		$KnockCountdown.wait_time = 10
	$KnockCountdown.start()

func check_mother_status():
	if night == false and Autoloads.mother <= 0:
		get_tree().change_scene_to_file("res://Scenes/mother_ending.tscn")

func check_player_status():
	if night == true and Autoloads.condition <= 0:
		get_tree().change_scene_to_file("res://Scenes/player_ending.tscn")

func _on_ambient_finished() -> void:
	$Ambient.play()


func _on_boss_finished() -> void:
	$Boss.play()
