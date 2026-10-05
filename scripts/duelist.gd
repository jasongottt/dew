extends "res://scripts/boss.gd"

# the rematch: two pistols, quicker on the draw
@export var second_fight := false

# the six places he dashes between
const SPOTS = [Vector2i(11, 5), Vector2i(17, 4), Vector2i(23, 5), Vector2i(11, 15), Vector2i(17, 16), Vector2i(23, 15)]
const DASH_SPEED = 500.0
const MAX_DASH = 1.5
const SHOTS = 3
const SHOT_GAP = 0.15
const PAUSE = 0.6
const FOLLOW_COLOR = Color(1, 0.2, 0.2, 0.8)
const LOCKED_COLOR = Color(1, 1, 1, 1)

var state = "dash"
var dash_to := Vector2.ZERO
var timer := 0.0
var rounds := 0
var side := 1
var directions = []
var shots_left := 0

func _ready():
	super()
	pick_spot()

func _physics_process(delta):
	if player == null or frozen():
		return
	if idle_time > 0:
		idle_time -= delta
		hide_lines()
		return
	# can't find you in the fog, wanders like everyone else
	if lost():
		hide_lines()
		state = "pause"
		timer = 0.0
		super(delta)
		return

	timer -= delta
	match state:
		"dash":
			velocity = global_position.direction_to(dash_to) * DASH_SPEED
			move_and_slide()
			if global_position.distance_to(dash_to) < 10 or timer < -MAX_DASH:
				velocity = Vector2.ZERO
				side = [-1, 1].pick_random()
				state = "aim"
				timer = 0.4 if second_fight else 0.5
				aim()
		"aim":
			aim()
			if timer <= 0:
				state = "locked"
				timer = 0.3 if second_fight else 0.4
				for line in lines():
					line.default_color = LOCKED_COLOR
		"locked":
			if timer <= 0:
				rounds += 1
				if rounds % 3 == 0:
					fan()
					end_round()
				else:
					state = "shoot"
					shots_left = SHOTS
					timer = 0.0
		"shoot":
			if timer <= 0:
				for direction in directions:
					fire(direction, shot_speed())
				shots_left -= 1
				timer = SHOT_GAP
				if shots_left == 0:
					end_round()
		"pause":
			if timer <= 0:
				pick_spot()

# follows you with the line(s) until it locks
func aim():
	var direction = global_position.direction_to(target())
	directions = [direction]
	if second_fight:
		# the second gun covers the side you'd dodge to
		directions.append(direction.rotated(deg_to_rad(30) * side))
	var all_lines = lines()
	for i in all_lines.size():
		all_lines[i].visible = true
		all_lines[i].default_color = FOLLOW_COLOR
		all_lines[i].points = [Vector2.ZERO, directions[i] * 1000]

# fanning the hammer every third round
func fan():
	var count = 7 if second_fight else 5
	var spread = 45.0 if second_fight else 30.0
	for i in count:
		var angle = lerp(-spread, spread, float(i) / (count - 1))
		fire(directions[0].rotated(deg_to_rad(angle)), shot_speed())

func end_round():
	hide_lines()
	state = "pause"
	timer = PAUSE

func pick_spot():
	var level = get_parent()
	var options = []
	for tile in SPOTS:
		var spot = level.tile_position(tile)
		if spot.distance_to(player.global_position) >= 120 and spot.distance_to(global_position) > 10:
			options.append(spot)
	if options.is_empty():
		options = SPOTS.map(func(tile): return level.tile_position(tile))
	dash_to = options.pick_random()
	state = "dash"
	timer = 0.0

func shot_speed():
	return 360.0 if second_fight else 300.0

func lines():
	return [$Line1, $Line2] if second_fight else [$Line1]

func hide_lines():
	$Line1.visible = false
	$Line2.visible = false
