extends "res://scripts/boss.gd"

const LIT_RANGE = 100.0
const LIT_AFTER_STRIKE = 1.0
const MARK_TIME = 1.5
const SUMMON_EVERY = 10.0

var mark_scene = preload("res://scenes/lightning.tscn")
var shadow_scene = preload("res://scenes/shadow.tscn")
var strike_timer := 4.0
var summon_timer := SUMMON_EVERY
var lit_time := 0.0

func _ready():
	super()
	# he only comes out in the dark
	if not get_parent().dark:
		get_parent().go_dark()

func _physics_process(delta):
	if player == null:
		return

	# only seen, and only hit, while something lights him up
	lit_time -= delta
	var lit = lit_time > 0 or player.whiteout > 0.3 or global_position.distance_to(player.global_position) < LIT_RANGE
	$AnimatedSprite2D.visible = lit
	collision_layer = 3 if lit else 1

	if frozen():
		return
	if idle_time > 0:
		idle_time -= delta
		return

	super(delta)

	strike_timer -= delta
	if strike_timer <= 0:
		call_lightning()
	summon_timer -= delta
	if summon_timer <= 0:
		summon_timer = SUMMON_EVERY
		var spawner = get_parent().get_node("EnemySpawner")
		for i in 2:
			spawner.place(shadow_scene.instantiate(), spawner.edge_point()[0])

func call_lightning():
	var angry = health < max_health / 2.0
	var count = 5 if angry else 3
	strike_timer = 3.0 if angry else 4.0
	var spots = []
	# one always lands on you, unless the fog's hiding you
	if not lost():
		spots.append(player.global_position)
	while spots.size() < count:
		spots.append(get_parent().random_spot())
	for spot in spots:
		var mark = mark_scene.instantiate()
		mark.time_left = MARK_TIME
		mark.global_position = spot
		get_parent().add_child(mark)

func lightning_struck():
	lit_time = LIT_AFTER_STRIKE
