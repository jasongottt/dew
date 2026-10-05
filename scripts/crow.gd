extends "res://scripts/basic_enemy.gd"

var direction := Vector2.ZERO

func _ready():
	super()
	# flies straight at where you were when it showed up
	if player:
		direction = global_position.direction_to(player.global_position)

func _physics_process(delta):
	if player == null or frozen():
		return
	global_position += direction * move_speed * delta
	# gone off the far side, no mark and no drop
	if not Rect2(-100, -100, 1800, 1100).has_point(global_position):
		queue_free()
