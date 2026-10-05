extends Node2D

@export var wave_time := 60.0
@export var next_level: PackedScene
# the merchant shows up once the level is cleared
@export var has_shop := false
# dark levels only show what's lit up
@export var dark := false
# a black cat runs across now and then, the mob chases it
@export var black_cat := false

const EXIT_TILES = [Vector2i(16, 19), Vector2i(17, 19), Vector2i(18, 19)]
const SHOP_TILE = Vector2i(17, 6)
const DARK_COLOR = Color(0.15, 0.15, 0.2)
# the cat runs between opposite gates
const CAT_GATES = [[Vector2i(17, 1), Vector2i(17, 19)], [Vector2i(8, 10), Vector2i(26, 10)]]

var shop_scene = preload("res://scenes/shop.tscn")
var cat_scene = preload("res://scenes/blackCat.tscn")
var cat_time := 0.0
var time_left := 0.0
var exit_open := false
var arrow_time := 0.0
var frozen := false

func _ready():
	time_left = wave_time
	cat_time = randf_range(25, 45)
	if dark:
		var shade = CanvasModulate.new()
		shade.name = "Dark"
		shade.color = DARK_COLOR
		add_child(shade)
		$Player/PointLight2D.visible = true

func _process(delta):
	# the flashbulb lights everything up for a moment
	if dark:
		$Dark.color = DARK_COLOR.lerp(Color.WHITE, $Player.whiteout)

	if time_left > 0:
		time_left -= delta
		if time_left <= 0:
			$EnemySpawner.set_process(false)
		if black_cat:
			cat_time -= delta
			if cat_time <= 0:
				send_cat()
				cat_time = randf_range(25, 45)
	elif not exit_open and get_tree().get_nodes_in_group("enemies").is_empty():
		open_exit()

	if exit_open:
		arrow_time += delta
		$ExitArrow.visible = fmod(arrow_time, 0.6) < 0.4

# the border tiles are what stop the player walking out of the gates
func open_exit():
	exit_open = true
	for tile in EXIT_TILES:
		$border.erase_cell(tile)
	if has_shop:
		var shop = shop_scene.instantiate()
		shop.position = tile_position(SHOP_TILE)
		add_child(shop)

func send_cat():
	var gates = CAT_GATES.pick_random().duplicate()
	gates.shuffle()
	var cat = cat_scene.instantiate()
	cat.global_position = tile_position(gates[0])
	cat.destination = tile_position(gates[1])
	add_child(cat)

func tile_position(tile):
	return $floor.to_global($floor.map_to_local(tile))

# an open floor tile away from walls and gates, optionally some distance from a point
func random_spot(away_from = null, min_distance = 0.0):
	var spots = []
	for cell in $floor.get_used_cells():
		var open = true
		for next in [cell, cell + Vector2i.UP, cell + Vector2i.DOWN, cell + Vector2i.LEFT, cell + Vector2i.RIGHT]:
			if $floor.get_cell_source_id(next) == -1 or $object.get_cell_source_id(next) != -1:
				open = false
		var spot = tile_position(cell)
		if open and (away_from == null or spot.distance_to(away_from) >= min_distance):
			spots.append(spot)
	return spots.pick_random()

func _on_player_died():
	Game.lives -= 1
	# everything stops for a second so you can see what got you
	frozen = true
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	frozen = false
	if Game.lives < 0:
		Game.game_over()
		return
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	for bullet in get_tree().get_nodes_in_group("enemy_bullets"):
		bullet.queue_free()
	$Player.respawn()

func _on_exit_body_entered(body):
	if exit_open and body == $Player:
		if next_level:
			get_tree().change_scene_to_packed.call_deferred(next_level)
		else:
			get_tree().reload_current_scene.call_deferred()
