extends Node2D

# short wait so a key held when you died doesn't skip straight past this
var wait = 1.0

func _process(delta):
	wait -= delta
	if wait <= 0 and Input.is_action_just_pressed("use"):
		Game.start()
