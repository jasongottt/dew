extends "res://scripts/basic_enemy.gd"

const EVERY = 3.0
const SHAKE_TIME = 0.4
const BURST = 3
const GAP = 0.12
const SPREAD = 10.0

var timer := EVERY
var burst_left := 0
var gap := 0.0

func _physics_process(delta):
	if player == null or frozen():
		return
	super(delta)

	if lost():
		timer = EVERY
		burst_left = 0
		$AnimatedSprite2D.position = Vector2.ZERO
		return

	timer -= delta
	# shakes just before the burst
	if timer < SHAKE_TIME:
		$AnimatedSprite2D.position = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	if timer <= 0:
		$AnimatedSprite2D.position = Vector2.ZERO
		timer = EVERY
		burst_left = BURST
		gap = 0.0

	if burst_left > 0:
		gap -= delta
		if gap <= 0:
			var angle = global_position.angle_to_point(target()) + deg_to_rad(randf_range(-SPREAD, SPREAD))
			fire(Vector2.RIGHT.rotated(angle))
			burst_left -= 1
			gap = GAP
