extends Node2D

func _process(_delta):
	if Input.is_action_just_pressed("use"):
		Game.reset()
		get_tree().change_scene_to_file("res://scenes/lvl1.tscn")
