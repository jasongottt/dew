extends "res://scripts/basic_enemy.gd"

# only moves while you do
func _physics_process(delta):
	if player == null or player.velocity.length() < 1:
		return
	super(delta)
