extends Node2D

@export var move_speed := 75.0
@export var step_distance := 100.0

var player: Node2D
var target_position: Vector2
var moving := false

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	randomize()

func _physics_process(delta):
	if player == null:
		return

	if not moving:
		var angle := global_position.angle_to_point(player.global_position)
		angle = snapped(angle, deg_to_rad(45.0)) + deg_to_rad(45.0) * randi_range(-1, 1)
		var direction := Vector2.RIGHT.rotated(angle)
		target_position = global_position + direction * step_distance
		moving = true

	global_position = global_position.move_toward(
		target_position,
		move_speed * delta
	)

	if global_position.is_equal_approx(target_position):
		moving = false
