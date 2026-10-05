extends "res://scripts/basic_enemy.gd"

const DUG_IN_HEALTH = 6
const EVERY = 3.0
const FLASH_TIME = 0.4
# gives up walking and digs in wherever he is after this long
const MAX_WALK = 8.0

var spot: Vector2
var dug_in := false
var walk_time := 0.0
var timer := EVERY

func _ready():
	super()
	# somewhere open, at least 3 tiles from the player
	spot = get_parent().random_spot(player.global_position, 120.0)

# walks to his spot, not at you
func target():
	return spot

func _physics_process(delta):
	if player == null or frozen():
		return

	if not dug_in:
		walk_time += delta
		if global_position.distance_to(spot) < 30 or walk_time > MAX_WALK:
			dig_in()
		else:
			super(delta)
		return

	if lost():
		timer = EVERY
		$AnimatedSprite2D.self_modulate = Color(1, 1, 1)
		return

	timer -= delta
	$AnimatedSprite2D.self_modulate = Color(3, 3, 3) if timer < FLASH_TIME else Color(1, 1, 1)
	if timer <= 0:
		for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			fire(direction)
		timer = EVERY

func dig_in():
	dug_in = true
	health = DUG_IN_HEALTH
	velocity = Vector2.ZERO
	moving = false
	$Cover.visible = true

# can't be pushed around once he's dug in
func shove(direction):
	if not dug_in:
		super(direction)
