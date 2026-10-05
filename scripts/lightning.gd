extends Node2D

# how close counts as being under the strike
const RADIUS = 40.0

# seconds until it strikes
@export var time_left := 2.0

func _process(delta):
	time_left -= delta
	visible = fmod(time_left, 0.3) > 0.1
	if time_left <= 0:
		strike()

func strike():
	var player = get_parent().get_node("Player")
	player.whiteout = max(player.whiteout, 0.6)
	get_tree().call_group("bosses", "lightning_struck")
	if global_position.distance_to(player.global_position) < RADIUS:
		player.take_hit()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.is_in_group("bosses") and global_position.distance_to(enemy.global_position) < RADIUS:
			enemy.die(false)
	queue_free()
