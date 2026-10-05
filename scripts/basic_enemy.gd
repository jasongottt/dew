extends CharacterBody2D

@export var move_speed := 75.0
@export var step_distance := 100.0
@export var death_mark_scene: PackedScene
@export var health := 1
@export var drop_chance := 0.15
# flying enemies go straight at the player and ignore walls
@export var flying := false

var pickup_scene = preload("res://scenes/pickup.tscn")
var player: Node2D
var target_position: Vector2
var moving := false
var move_direction := Vector2.ZERO
var dead := false

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	randomize()
	$PointLight2D.visible = get_parent().get("dark") == true

func _physics_process(delta):
	# frozen by the flashbulb
	if player == null or player.has_effect("flashbulb"):
		return

	if flying:
		if not player.has_effect("fog"):
			move_direction = global_position.direction_to(target())
		velocity = move_direction * move_speed
		move_and_slide()
		return

	if not moving:
		var angle = global_position.angle_to_point(target())
		if player.has_effect("fog"):
			angle = randf() * TAU
		angle = snapped(angle, deg_to_rad(45.0)) + deg_to_rad(45.0) * randi_range(-1, 1)

		move_direction = Vector2.RIGHT.rotated(angle)
		target_position = global_position + move_direction * step_distance
		moving = true

	if moving:
		velocity = move_direction * move_speed
		move_and_slide()
		if get_slide_collision_count() > 0:
			velocity = Vector2.ZERO
			moving = false
			return

		if is_on_wall():
			velocity = Vector2.ZERO
			moving = false
			return

		if global_position.distance_to(target_position) <= move_speed * delta:
			global_position = target_position
			velocity = Vector2.ZERO
			moving = false

# a burning road flare pulls enemies away from the player
func target():
	var flares = get_tree().get_nodes_in_group("flares")
	if flares.is_empty():
		return player.global_position
	var nearest = flares[0]
	for flare in flares:
		if global_position.distance_to(flare.global_position) < global_position.distance_to(nearest.global_position):
			nearest = flare
	return nearest.global_position

# fog rolled in, head off somewhere random
func lose_track():
	move_direction = Vector2.RIGHT.rotated(randf() * TAU)
	moving = false

func hit(damage):
	health -= damage
	if health <= 0:
		die()
		return
	modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)

func die(drop = true):
	if dead:
		return
	dead = true
	if death_mark_scene:
		var mark = death_mark_scene.instantiate()
		mark.global_position = global_position
		get_parent().add_child(mark)

	if drop and randf() < drop_chance:
		var pickup = pickup_scene.instantiate()
		pickup.kind = Game.random_drop()
		pickup.global_position = global_position
		get_parent().call_deferred("add_child", pickup)

	queue_free()
