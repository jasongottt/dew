extends "res://scripts/basic_enemy.gd"

# shoves other enemies out of his way, and knocks a lookout out of cover
func bumped(other):
	if other.get("dug_in"):
		other.die(false)
	else:
		other.shove(global_position.direction_to(other.global_position))
