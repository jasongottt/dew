extends Node2D

var lifetime = 6.0

func _ready():
	$PointLight2D.visible = get_parent().get("dark") == true

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
