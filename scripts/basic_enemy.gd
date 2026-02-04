extends CharacterBody2D

@export var move_speed := 75.0
@export var step_distance := 100.0

var player: Node2D
var target_position: Vector2
var moving := false
var move_direction := Vector2.ZERO

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	randomize()

func _physics_process(delta):
	if player == null:
		return

	if not moving:
		var angle = global_position.angle_to_point(player.global_position)
		angle = snapped(angle, deg_to_rad(45.0)) + deg_to_rad(45.0) * randi_range(-1, 1)

		move_direction = Vector2.RIGHT.rotated(angle)
		target_position = global_position + move_direction * step_distance
		moving = true

	if moving:
		velocity = move_direction * move_speed
		move_and_slide()

		if is_on_wall():
			velocity = Vector2.ZERO
			moving = false
			return

		if global_position.distance_to(target_position) <= move_speed * delta:
			global_position = target_position
			velocity = Vector2.ZERO
			moving = false
