extends Node2D

@export var wave_time := 60.0
@export var next_level: PackedScene
# the merchant shows up once the level is cleared
@export var has_shop := false
# dark levels only show what's lit up
@export var dark := false

const EXIT_TILES = [Vector2i(16, 19), Vector2i(17, 19), Vector2i(18, 19)]
const SHOP_TILE = Vector2i(17, 6)
const DARK_COLOR = Color(0.15, 0.15, 0.2)

var shop_scene = preload("res://scenes/shop.tscn")
var time_left := 0.0
var exit_open := false
var arrow_time := 0.0

func _ready():
	time_left = wave_time
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
		shop.position = $floor.to_global($floor.map_to_local(SHOP_TILE))
		add_child(shop)

func _on_player_died():
	Game.lives -= 1
	if Game.lives < 0:
		Game.game_over()
		return
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	$Player.respawn()

func _on_exit_body_entered(body):
	if exit_open and body == $Player:
		if next_level:
			get_tree().change_scene_to_packed.call_deferred(next_level)
		else:
			get_tree().reload_current_scene.call_deferred()
