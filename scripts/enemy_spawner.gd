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
	var edge = SPAWN_TILES.keys().pick_random()
	var tile = SPAWN_TILES[edge].pick_random()
	spawn_at(tile)

func spawn_at(tile):
	var enemy = enemy_scenes.pick_random().instantiate()
	enemy.global_position = tiles.to_global(tiles.map_to_local(tile))
	get_parent().add_child.call_deferred(enemy)

# one enemy on every gate tile at once
func rush():
	for edge in SPAWN_TILES:
		for tile in SPAWN_TILES[edge]:
			spawn_at(tile)
