extends Node

const START_LIVES = 3

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

func random_drop():
	var total = 0
	for kind in DROPS:
		total += DROPS[kind]
	var roll = randi() % total
	for kind in DROPS:
		roll -= DROPS[kind]
		if roll < 0:
			return kind
