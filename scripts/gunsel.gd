extends "res://scripts/basic_enemy.gd"

# only fires when you're lined up with him, straight or diagonal
const LINE_UP = 10.0
const AIM_TIME = 0.5
const COOLDOWN = 2.0

var aim_time := 0.0
var aim_direction := Vector2.ZERO
var cooldown := 0.0

func _physics_process(delta):
	if player == null or frozen():
		return
	cooldown -= delta

	if aim_time > 0:
		if lost():
			stop_aiming()
		else:
			aim_time -= delta
			if aim_time <= 0:
				stop_aiming()
				fire(aim_direction)
				cooldown = COOLDOWN
			return

	if cooldown <= 0 and not lost():
		var angle = global_position.angle_to_point(target())
		var line = snapped(angle, deg_to_rad(45.0))
		if abs(angle_difference(angle, line)) < deg_to_rad(LINE_UP):
			aim_direction = Vector2.RIGHT.rotated(line)
			aim_time = AIM_TIME
			# red while he's aiming
			$AnimatedSprite2D.self_modulate = Color(2, 0.4, 0.4)
			return

	super(delta)

func stop_aiming():
	aim_time = 0
	$AnimatedSprite2D.self_modulate = Color(1, 1, 1)
