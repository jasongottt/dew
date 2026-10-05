extends Node

# seconds each timed power-up lasts
const DURATIONS = {
	"coffee": 15.0,
	"sawed_off": 12.0,
	"flashbulb": 3.0,
	"fog": 6.0,
	"whiskey": 5.0,
}

var flare_scene = preload("res://scenes/flare.tscn")
var ghost_scene = preload("res://scenes/ghost.tscn")
var lightning_scene = preload("res://scenes/lightning.tscn")

@onready var player = get_parent()

func use(kind):
	if kind in DURATIONS:
		player.effects[kind] = DURATIONS[kind]

	if kind == "flashbulb":
		player.whiteout = 1.0
	elif kind == "fog":
		get_tree().call_group("enemies", "lose_track")
	elif kind == "lightning":
		kill_everything()
		drop(lightning_scene)
	elif kind == "flare":
		drop(flare_scene)
	elif kind == "ghost":
		var ghost = ghost_scene.instantiate()
		ghost.player = player
		ghost.global_position = player.global_position
		player.get_parent().add_child.call_deferred(ghost)
	elif kind == "lucky_coin":
		flip_coin()
	elif kind == "trench_coat":
		# worn until something hits you
		player.effects["trench_coat"] = INF

# leaves something on the ground where the player is standing
func drop(scene):
	var thing = scene.instantiate()
	thing.global_position = player.global_position
	player.get_parent().add_child.call_deferred(thing)

func kill_everything():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.is_in_group("bosses"):
			enemy.damage_boss(10)
		else:
			enemy.die(false)

func flip_coin():
	var heads = randf() < 0.5
	if heads:
		kill_everything()
	else:
		player.get_parent().get_node("EnemySpawner").rush()

	var label = Label.new()
	label.text = "HEADS" if heads else "TAILS"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-50, -60)
	label.size = Vector2(100, 24)
	player.add_child(label)
	await get_tree().create_timer(1.0).timeout
	label.queue_free()
