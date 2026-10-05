extends Area2D

const RADIUS = 60.0

var player: Node2D
var lifetime = 10.0
var angle = 0.0

func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0 or not is_instance_valid(player):
		queue_free()
		return
	angle += delta * 5.0
	global_position = player.global_position + Vector2.RIGHT.rotated(angle) * RADIUS
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.die()
