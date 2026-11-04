extends "res://scripts/basic_enemy.gd"

func _ready():
	super()
	# on dark levels it's black in the dark, so it only shows up where something
	# lights it (the flashbulb lights everything). on lit levels it's see-through
	if get_parent().get("dark") != true:
		$AnimatedSprite2D.modulate.a = 0.35
