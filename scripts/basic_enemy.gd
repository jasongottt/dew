extends CharacterBody2D

@export var move_speed := 75.0
@export var step_distance := 100.0
@export var death_mark_scene: PackedScene
@export var health := 1
@export var drop_chance := 0.15
# flying enemies go straight at the player and ignore walls
@export var flying := false
# the spawner sends this many at once
@export var group_size := 1
# comes in from anywhere around the edge instead of a gate
@export var edge_spawn := false

var pickup_scene = preload("res://scenes/pickup.tscn")
var bullet_scene = preload("res://scenes/enemyBullet.tscn")
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
	if player == null or frozen():
		return

	if flying:
		if not lost():
			move_direction = global_position.direction_to(target())
		velocity = move_direction * move_speed
		move_and_slide()
		return

	if not moving:
		var angle = global_position.angle_to_point(target())
		if lost():
			angle = randf() * TAU
		angle = snapped(angle, deg_to_rad(45.0)) + deg_to_rad(45.0) * randi_range(-1, 1)

		move_direction = Vector2.RIGHT.rotated(angle)
		target_position = global_position + move_direction * step_distance
		moving = true

	if moving:
		velocity = move_direction * move_speed
		move_and_slide()
		if get_slide_collision_count() > 0:
			for i in get_slide_collision_count():
				var other = get_slide_collision(i).get_collider()
				if other.is_in_group("enemies"):
					bumped(other)
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

# a burning road flare or the black cat pulls enemies away from the player
func target():
	var lures = get_tree().get_nodes_in_group("flares") + get_tree().get_nodes_in_group("cats")
	if lures.is_empty():
		return player.global_position
	var nearest = lures[0]
	for lure in lures:
		if global_position.distance_to(lure.global_position) < global_position.distance_to(nearest.global_position):
			nearest = lure
	return nearest.global_position

# the flashbulb stops everything
func frozen():
	return player.has_effect("flashbulb")

# in the fog nobody can find you
func lost():
	return player.has_effect("fog")

# fog rolled in, head off somewhere random
func lose_track():
	move_direction = Vector2.RIGHT.rotated(randf() * TAU)
	moving = false

# walked into another enemy, the enforcer does something about it
func bumped(_other):
	pass

# pushed a step in some direction
func shove(direction):
	move_direction = direction
	target_position = global_position + direction * step_distance
	moving = true

func fire(direction, speed = 160.0, offset = 0.0):
	var bullet = bullet_scene.instantiate()
	bullet.direction = direction
	bullet.speed = speed
	bullet.global_position = global_position + direction * offset
	get_parent().add_child(bullet)

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
