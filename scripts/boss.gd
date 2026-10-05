extends "res://scripts/basic_enemy.gd"

var max_health := 0
var idle_time := 0.0

func _ready():
	super()
	add_to_group("bosses")
	max_health = health

# lightning and the lucky coin hurt a boss instead of killing it
func damage_boss(amount):
	hit(amount)

# only goes down once his health runs out
func die(drop = true):
	if health > 0:
		return
	super(drop)

# gives you a moment after you respawn
func idle_for(seconds):
	idle_time = seconds

# bosses don't get pushed around
func shove(_direction):
	pass

# the man in the rain cares about this, other bosses don't
func lightning_struck():
	pass
