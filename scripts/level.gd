extends Node2D

@export var wave_time := 60.0
# the merchant shows up once the level is cleared
@export var has_shop := false
# dark levels only show what's lit up
@export var dark := false
# a black cat runs across now and then, the mob chases it
@export var black_cat := false
# rain over the whole level, see rain.tscn. untick it anywhere indoors
@export var raining := true
# on lit levels there's a pool of light around you that gets darker in rings
# the farther out it goes, see gloom.tscn. dark levels have their own
@export var gloom := true
# makes this a boss fight: no timer, no regular spawns
@export var boss_scene: PackedScene

const EXIT_TILES = [Vector2i(16, 19), Vector2i(17, 19), Vector2i(18, 19)]
# the top gate, where you walk in from the level before
const ENTRANCE_TILES = [Vector2i(16, 1), Vector2i(17, 1), Vector2i(18, 1)]
const SHOP_TILE = Vector2i(17, 6)
const DARK_COLOR = Color(0.15, 0.15, 0.2)
# the cat runs between opposite gates
const CAT_GATES = [[Vector2i(17, 1), Vector2i(17, 19)], [Vector2i(8, 10), Vector2i(26, 10)]]

var shop_scene = preload("res://scenes/shop.tscn")
var cat_scene = preload("res://scenes/blackCat.tscn")
var rain_scene = preload("res://scenes/rain.tscn")
var gloom_scene = preload("res://scenes/gloom.tscn")
var cat_time := 0.0
var time_left := 0.0
var exit_open := false
var arrow_time := 0.0
var frozen := false
var boss = null
var leaving := false
# where the Player sits in the scene. you come back here after dying
var start_spot := Vector2()
# which tiles the mob can walk on, so they can find a way around walls and gaps
var paths = AStarGrid2D.new()

func _ready():
	time_left = wave_time
	cat_time = randf_range(25, 45)
	make_gap()
	map_paths()
	check_start()
	start_spot = $Player.position
	if raining:
		make_rain()
	if dark:
		go_dark()
	if boss_scene:
		time_left = 0
		$EnemySpawner.set_process(false)
		boss = boss_scene.instantiate()
		boss.global_position = tile_position(SHOP_TILE)
		add_child(boss)
	# after the boss, the man in the rain makes it dark
	if gloom and not dark:
		make_gloom()

func go_dark():
	dark = true
	var shade = CanvasModulate.new()
	shade.name = "Dark"
	shade.color = DARK_COLOR
	add_child(shade)
	$Player/PointLight2D.visible = true
	if has_node("Gloom"):
		$Gloom.free()

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
	# only between gates that are open on this level
	var open = []
	for gate in $EnemySpawner.open_gates():
		open.append_array(gate)
	var runs = CAT_GATES.filter(func(run): return run[0] in open and run[1] in open)
	if runs.is_empty():
		return
	var gates = runs.pick_random().duplicate()
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
			if $floor.get_cell_source_id(next) == -1 or $object.get_cell_source_id(next) != -1 or in_gap(next):
				open = false
		var spot = tile_position(cell)
		if open and (away_from == null or spot.distance_to(away_from) >= min_distance):
			spots.append(spot)
	return spots.pick_random()

# the gap between two roofs. paint it on a tile layer called "gap":
# nobody can walk over it, but shots fly straight across
func make_gap():
	if not has_node("gap"):
		return
	# the tiles' own shapes would stop bullets too, so it gets its own.
	# layer 1 stops the mob and layer 4 stops the player, bullets check neither
	$gap.collision_enabled = false
	var body = StaticBody2D.new()
	body.collision_layer = 1 + 8
	body.collision_mask = 0
	var square = RectangleShape2D.new()
	square.size = $gap.tile_set.tile_size
	for cell in $gap.get_used_cells():
		var shape = CollisionShape2D.new()
		shape.shape = square
		shape.position = $gap.map_to_local(cell)
		body.add_child(shape)
	$gap.add_child(body)

func make_rain():
	var rain = rain_scene.instantiate()
	var area = floor_area()
	rain.position = area.position
	rain.size = area.size
	rain.material.set_shader_parameter("size", rain.size)
	add_child(rain)

func make_gloom():
	var shade = gloom_scene.instantiate()
	var area = floor_area()
	shade.position = area.position
	shade.size = area.size
	shade.follow = $Player
	add_child(shade)

# wherever there's floor (it runs under the walls too), not the black outside
func floor_area():
	var tile = Vector2($floor.tile_set.tile_size) * $floor.scale
	var area = $floor.get_used_rect()
	return Rect2($floor.position + Vector2(area.position) * tile, Vector2(area.size) * tile)

func in_gap(cell):
	return has_node("gap") and $gap.get_cell_source_id(cell) != -1

func map_paths():
	paths.region = $floor.get_used_rect().merge($border.get_used_rect())
	paths.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	paths.update()
	for x in range(paths.region.position.x, paths.region.end.x):
		for y in range(paths.region.position.y, paths.region.end.y):
			paths.set_point_solid(Vector2i(x, y), not walkable(Vector2i(x, y)))

# where the Player sits in the scene is where you start (and walk in to).
# if that's inside a wall or the gap you'd be stuck, so it moves you
# to the nearest open tile and says so in the debugger
func check_start():
	var cell = cell_at($Player.global_position)
	if paths.is_in_boundsv(cell) and not paths.is_point_solid(cell):
		return
	var nearest = null
	for x in range(paths.region.position.x, paths.region.end.x):
		for y in range(paths.region.position.y, paths.region.end.y):
			var open = Vector2i(x, y)
			if paths.is_point_solid(open) or $floor.get_cell_source_id(open) == -1 or $border.get_cell_source_id(open) != -1:
				continue
			if nearest == null or Vector2(open).distance_to(Vector2(cell)) < Vector2(nearest).distance_to(Vector2(cell)):
				nearest = open
	push_warning("%s: the Player starts inside a wall or the gap, moved to tile %s" % [scene_file_path, nearest])
	$Player.global_position = tile_position(nearest)

func walkable(cell):
	# off the edge of the map, apart from the gates
	if $floor.get_cell_source_id(cell) == -1 and $border.get_cell_source_id(cell) == -1:
		return false
	if in_gap(cell):
		return false
	# any tile with a wall shape on it
	for layer in find_children("*", "TileMapLayer", false):
		var tile = layer.get_cell_tile_data(cell)
		if layer.collision_enabled and tile and tile.get_collision_polygons_count(0) > 0:
			return false
	return true

# the middle of the next tile to walk to, on the way from one point to another.
# null when nothing's in the way and you can just go straight there
func way_to(from, to):
	if clear_line(from, to):
		return null
	var start = cell_at(from)
	var end = cell_at(to)
	for cell in [start, end]:
		if not paths.is_in_boundsv(cell) or paths.is_point_solid(cell):
			return null
	var path = paths.get_id_path(start, end)
	if path.size() < 2:
		return null
	# they're nearly a tile wide, so line up in the middle of this one
	# first or they catch on the corners
	if from.distance_to(tile_position(start)) > 2:
		return tile_position(start)
	return tile_position(path[1])

# could an enemy walk straight from one point to the other.
# they're nearly a tile wide, so it checks down both sides too
func clear_line(from, to):
	var side = from.direction_to(to).orthogonal() * 15
	var checks = ceili(from.distance_to(to) / 10.0)
	for i in checks + 1:
		var point = from.lerp(to, float(i) / max(checks, 1))
		for spot in [point - side, point, point + side]:
			var cell = cell_at(spot)
			if not paths.is_in_boundsv(cell) or paths.is_point_solid(cell):
				return false
	return true

func cell_at(spot):
	return $floor.local_to_map($floor.to_local(spot))

# the way you walk in from the level before: down through the top gate,
# then around anything in the way to "to" (wherever the Player sits in the scene).
# everything's in the level's own space, since the level is still scrolling
func walk_in(from, to):
	var door = ENTRANCE_TILES[0]
	for tile in ENTRANCE_TILES:
		if abs(to_local(tile_position(tile)).x - from.x) < abs(to_local(tile_position(door)).x - from.x):
			door = tile
	var end = cell_at(to_global(to))
	# somewhere it can't get to, just head straight there
	if not paths.is_in_boundsv(end) or paths.is_point_solid(end) or paths.is_point_solid(door):
		return [to]
	var points = []
	for cell in paths.get_id_path(door, end).slice(0, -1):
		points.append(to_local(tile_position(cell)))
	points.append(to)
	return points

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
	# a boss keeps the damage you've done, everything else goes
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.is_in_group("bosses"):
			enemy.queue_free()
	for bullet in get_tree().get_nodes_in_group("enemy_bullets"):
		bullet.queue_free()
	get_tree().call_group("bosses", "idle_for", 2.0)
	$Player.position = start_spot
	$Player.respawn()

func _on_exit_body_entered(body):
	if exit_open and not leaving and body == $Player:
		leaving = true
		Game.scroll_to.call_deferred(load(Game.level_after(scene_file_path)))
