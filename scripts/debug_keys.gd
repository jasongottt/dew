extends CanvasLayer

# shortcuts for testing. Game only adds this when you run from the editor,
# a normal (release) export doesn't have them
#   F1  next level
#   F2  restart this level
#   F3  end the wave now, the exit opens
#   F4  give a random power-up
#   F5  +10 coins
#   F6  invincible on/off
#   F7  noir filter on/off (works on the title screen too)
#   F9  enemy outlines on/off (F8 is godot's stop button)

const POWERUPS = ["coffee", "sawed_off", "flashbulb", "fog", "flare", "trench_coat", "whiskey", "lucky_coin", "ghost", "lightning"]
const MESSAGE_TIME = 1.5

var invincible := false
var message := ""
var message_time := 0.0
var label: Label

func _ready():
	layer = 100
	label = Label.new()
	label.position = Vector2(1300, 10)
	label.size = Vector2(290, 60)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(label)

func _process(delta):
	message_time -= delta
	var lines = []
	if invincible:
		lines.append("invincible")
	if message_time > 0:
		lines.append(message)
	label.text = "\n".join(lines)

func _physics_process(_delta):
	var player = level_player()
	if invincible and player:
		player.invincible = true

func _unhandled_key_input(event):
	if not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_F7:
		Game.filter.visible = not Game.filter.visible
		say("filter " + ("on" if Game.filter.visible else "off"))
		return
	if event.physical_keycode == KEY_F9:
		Game.outlines = not Game.outlines
		say("outlines " + ("on" if Game.outlines else "off"))
		return
	var level = current_level()
	if level == null:
		return
	match event.physical_keycode:
		KEY_F1:
			say("next level")
			get_tree().change_scene_to_file(Game.level_after(level.scene_file_path))
		KEY_F2:
			say("restart")
			get_tree().reload_current_scene()
		KEY_F3:
			say("wave over")
			end_wave(level)
		KEY_F4:
			var kind = POWERUPS.filter(func(k): return k != Game.held_item).pick_random()
			Game.held_item = kind
			say(kind)
		KEY_F5:
			Game.coins += 10
			say("+10 coins")
		KEY_F6:
			invincible = not invincible
			if not invincible:
				level.get_node("Player").invincible = false

# the level you're playing, or null on the title, game over, or mid-scroll
func current_level():
	var scene = get_tree().current_scene
	if scene == null or not scene.has_method("open_exit"):
		return null
	if scene.leaving or scene.process_mode == Node.PROCESS_MODE_DISABLED:
		return null
	return scene

func level_player():
	var level = current_level()
	if level == null:
		return null
	return level.get_node("Player")

func end_wave(level):
	level.time_left = 0
	level.get_node("EnemySpawner").set_process(false)
	kill_everyone()
	# anything the spawner sent this frame shows up at the end of it
	await get_tree().process_frame
	kill_everyone()

# bosses included
func kill_everyone():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.health = 0
		enemy.die(false)

func say(text):
	message = text
	message_time = MESSAGE_TIME
