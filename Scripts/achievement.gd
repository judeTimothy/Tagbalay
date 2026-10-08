extends Control
@onready var mother = preload("res://Assets/Achievements/Achievement_01.png")
@onready var player = preload("res://Assets/Achievements/Achievement_02.png")
@onready var agree = preload("res://Assets/Achievements/Achievement_03.png")
@onready var refuse = preload("res://Assets/Achievements/Achievement_04.png")
@onready var shady = preload("res://Assets/Achievements/Achievement_05.png")
@onready var animosity = preload("res://Assets/Achievements/Achievement_06.png")
var achievement = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match achievement:
		1:
			$Achievement.texture = mother
		2:
			$Achievement.texture = player
		3:
			$Achievement.texture = agree
		4:
			$Achievement.texture = refuse
		5:
			$Achievement.texture = shady
		6:
			$Achievement.texture = animosity
		_:
			$Achievement.texture = mother
	
	$AnimationPlayer.play("show_achievement")
		
