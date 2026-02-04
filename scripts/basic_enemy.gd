extends Node2D

var movespeed = 200
var player = null

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)

func _physics_process(delta):
	var angle: float = rad_to_deg(global_position.angle_to_point(self.global_position))
