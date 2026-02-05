extends Node2D

@export var enemy_scene = preload("res://scenes/basicEnemy.tscn")
@export var tile_size := 16

const SPAWN_TILES := {
	"top": [
		Vector2i(763, 92), Vector2i(803, 92), Vector2i(843, 92)
	],
	"bottom": [
		Vector2i(763, 812), Vector2i(803, 812), Vector2i(843, 812)
	],
	"left": [
		Vector2i(441, 412), Vector2i(441, 452), Vector2i(441, 492)
	],
	"right": [
		Vector2i(1164, 412), Vector2i(1164, 452), Vector2i(1164, 492)
	]
}
var time_elapsed: float = 0.0
var wait_time: float = 1.0

func _process(delta):
	time_elapsed += delta
	if time_elapsed >= wait_time:
		time_elapsed -= wait_time # Reset the timer
		spawn_enemy()
		
func spawn_enemy():
	var edge = SPAWN_TILES.keys().pick_random()
	var tile = SPAWN_TILES[edge].pick_random()

	var enemy = enemy_scene.instantiate()
	enemy.global_position = tile
	get_parent().add_child(enemy)
