extends Node2D

# put a scene in more than once to make it spawn more often
@export var enemy_scenes: Array[PackedScene] = [preload("res://scenes/basicEnemy.tscn")]
@export var tiles: TileMapLayer
@export var wait_time: float = 1.0

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

func _process(delta):
	time_elapsed += delta
	if time_elapsed >= wait_time:
		time_elapsed -= wait_time # Reset the timer
		spawn_enemy()
		
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

	# a group takes up one tile each in the same gate
	var gate = SPAWN_TILES[SPAWN_TILES.keys().pick_random()].duplicate()
	gate.shuffle()
	place(enemy, tile_position(gate[0]))
	for i in range(1, min(enemy.group_size, gate.size())):
		place(scene.instantiate(), tile_position(gate[i]))

func spawn_at(tile):
	place(enemy_scenes.pick_random().instantiate(), tile_position(tile))

func place(enemy, spot):
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
