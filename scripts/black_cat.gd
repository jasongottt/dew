extends Area2D

# runs across from one gate to the other, the mob chases it to their doom
var destination: Vector2
var speed = 140.0

func _physics_process(delta):
	global_position = global_position.move_toward(destination, speed * delta)
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies") and not body.is_in_group("bosses"):
			body.die()
	if global_position == destination:
		queue_free()
