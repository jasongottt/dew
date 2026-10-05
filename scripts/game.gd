extends Node

const START_LIVES = 3
# how long the scroll between levels takes, and how far it scrolls.
# 840 is one map's height (21 tiles), so the old bottom gate meets the new top gate
const SCROLL_TIME = 1.5
const SCROLL_DISTANCE = 840.0

# how often each drop shows up compared to the others
const DROPS = {
	"coin": 40,
	"coin5": 8,
	"life": 2,
	"coffee": 5,
	"sawed_off": 5,
	"flashbulb": 4,
	"fog": 4,
	"flare": 4,
	"trench_coat": 3,
	"whiskey": 3,
	"lucky_coin": 3,
	"ghost": 2,
	"lightning": 2,
}

var lives = START_LIVES
var coins = 0
var held_item = ""
var boots = 0
var gun = 0
var ammo = 0

func reset():
	lives = START_LIVES
	coins = 0
	held_item = ""
	boots = 0
	gun = 0
	ammo = 0

func game_over():
	get_tree().change_scene_to_file.call_deferred("res://scenes/game_over.tscn")

# walking off the bottom: the old level slides up and away while the next one
# slides up into place and the player walks down onto it, like prairie king.
# lives here because the old level gets deleted halfway through
func scroll_to(scene):
	var tree = get_tree()
	var old = tree.current_scene
	var new = scene.instantiate()
	var level_name = new.name

	# nothing moves, spawns or counts down until the scroll is done
	old.process_mode = Node.PROCESS_MODE_DISABLED
	new.process_mode = Node.PROCESS_MODE_DISABLED
	new.position.y = SCROLL_DISTANCE
	tree.root.add_child(new)

	# the old level's darkness would cover both levels during the scroll
	if old.has_node("Dark"):
		old.get_node("Dark").free()
	old.get_node("HUD").visible = false

	# swap in the new level's player right where the old one is standing
	var old_player = old.get_node("Player")
	var player = new.get_node("Player")
	var start = player.position
	player.position = old_player.position - Vector2(0, SCROLL_DISTANCE)
	old_player.visible = false
	for sprite in [player.get_node("top"), player.get_node("bottom")]:
		sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	player.get_node("top").play("down")
	player.get_node("bottom").play("walk")

	var tween = create_tween().set_parallel()
	tween.tween_property(old, "position:y", -SCROLL_DISTANCE, SCROLL_TIME)
	tween.tween_property(new, "position:y", 0.0, SCROLL_TIME)
	tween.tween_property(player, "position", start, SCROLL_TIME)
	await tween.finished

	# take the old level out first so the new one can have its proper name back
	tree.root.remove_child(old)
	old.queue_free()
	new.name = level_name
	tree.current_scene = new
	for sprite in [player.get_node("top"), player.get_node("bottom")]:
		sprite.process_mode = Node.PROCESS_MODE_INHERIT
	new.process_mode = Node.PROCESS_MODE_INHERIT

func random_drop():
	var total = 0
	for kind in DROPS:
		total += DROPS[kind]
	var roll = randi() % total
	for kind in DROPS:
		roll -= DROPS[kind]
		if roll < 0:
			return kind
