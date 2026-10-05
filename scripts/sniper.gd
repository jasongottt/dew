extends "res://scripts/basic_enemy.gd"

# stays in the dark gateway he spawned in and never moves
const EVERY = 4.0
const AIM_TIME = 1.0
const SHOT_SPEED = 400.0

var timer := EVERY
var aim_time := 0.0
var aim_direction := Vector2.ZERO

func _physics_process(delta):
	if player == null or frozen():
		return

	if lost():
		aim_time = 0
		timer = EVERY
		$AimLine.visible = false
		return

	if aim_time > 0:
		aim_time -= delta
		if aim_time <= 0:
			$AimLine.visible = false
			# starts the bullet out past the gate's dark cover
			fire(aim_direction, SHOT_SPEED, 45.0)
			timer = EVERY
		return

	timer -= delta
	if timer <= 0:
		# locks onto where you are right now
		aim_direction = global_position.direction_to(target())
		aim_time = AIM_TIME
		$AimLine.points = [Vector2.ZERO, aim_direction * 1000]
		$AimLine.visible = true
