extends Node2D

# put a scene in more than once to make it spawn more often
@export var enemy_scenes: Array[PackedScene] = [preload("res://scenes/basicEnemy.tscn")]
@export var tiles: TileMapLayer
# seconds between spawns at the start of the wave, and by the end of it
@export var wait_start: float = 2.0
@export var wait_end: float = 0.8
# how many arrive at once at the start of the wave, and by the end of it
@export var group_start: int = 1
@export var group_end: int = 2

const SPAWN_TILES := {
	"top": [
		Vector2i(16, 1), Vector2i(17, 1), Vector2i(18, 1)
	],
	"bottom": [
		Vector2i(16, 19), Vector2i(17, 19), Vector2i(18, 19)
	],
	"left": [
		Vector2i(8, 9), Vector2i(8, 10), Vector2i(8, 11)
	],
	"right": [
		Vector2i(26, 9), Vector2i(26, 10), Vector2i(26, 11)
	]
}
var time_elapsed: float = 0.0
# spots handed out since the last frame, those enemies aren't in the level yet
var placed_this_frame = []

func _process(delta):
	time_elapsed += delta
	var wait_time = lerp(wait_start, wait_end, progress())
	if time_elapsed >= wait_time:
		time_elapsed -= wait_time # Reset the timer
		for i in roundi(lerp(float(group_start), float(group_end), progress())):
			spawn_enemy()

# how far through the wave we are, 0 at the start and 1 at the end
func progress():
	var level = get_parent()
	return clamp(1.0 - level.time_left / level.wave_time, 0.0, 1.0)
		
func spawn_enemy():
	var scene = enemy_scenes.pick_random()
	var enemy = scene.instantiate()

	if enemy.edge_spawn:
		# a group comes in side by side along the edge
		var spot = edge_point()
		place(enemy, spot[0])
		for i in range(1, enemy.group_size):
			place(scene.instantiate(), spot[0] + spot[1] * 50 * i)
		return

	# a group takes up one free tile each in the same gate.
	# if every gate is busy this one just doesn't come
	var gates = []
	for gate_tiles in SPAWN_TILES.values():
		var free = gate_tiles.filter(func(tile): return is_free(tile_position(tile)))
		if not free.is_empty():
			gates.append(free)
	if gates.is_empty():
		enemy.free()
		return
	var gate = gates.pick_random()
	gate.shuffle()
	place(enemy, tile_position(gate[0]))
	for i in range(1, min(enemy.group_size, gate.size())):
		place(scene.instantiate(), tile_position(gate[i]))

func spawn_at(tile):
	if is_free(tile_position(tile)):
		place(enemy_scenes.pick_random().instantiate(), tile_position(tile))

# two enemies started exactly on top of each other lock together
# and never come out of the gate, so never put one where another is
func is_free(spot):
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(spot) < 30:
			return false
	for taken in placed_this_frame:
		if taken.distance_to(spot) < 30:
			return false
	return true

func place(enemy, spot):
	# by the end of the frame they're in the level and count for themselves
	if placed_this_frame.is_empty():
		placed_this_frame.clear.call_deferred()
	placed_this_frame.append(spot)
	enemy.global_position = spot
	get_parent().add_child.call_deferred(enemy)

func tile_position(tile):
	return tiles.to_global(tiles.map_to_local(tile))

# a random point on the ring just outside the arena walls,
# and which way runs along that side
func edge_point():
	var top_left = tile_position(Vector2i(8, 1))
	var bottom_right = tile_position(Vector2i(26, 19))
	var x = randf_range(top_left.x, bottom_right.x)
	var y = randf_range(top_left.y, bottom_right.y)
	match randi() % 4:
		0:
			return [Vector2(x, top_left.y), Vector2.RIGHT]
		1:
			return [Vector2(x, bottom_right.y), Vector2.RIGHT]
		2:
			return [Vector2(top_left.x, y), Vector2.DOWN]
		_:
			return [Vector2(bottom_right.x, y), Vector2.DOWN]

# one enemy on every gate tile at once
func rush():
	for edge in SPAWN_TILES:
		for tile in SPAWN_TILES[edge]:
			spawn_at(tile)
