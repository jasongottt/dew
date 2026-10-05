extends Area2D

const RADIUS = 60.0
# bosses only take a hit from him this often
const BOSS_COOLDOWN = 0.5

var player: Node2D
var lifetime = 10.0
var angle = 0.0
var boss_cooldown = 0.0

func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0 or not is_instance_valid(player):
		queue_free()
		return
	angle += delta * 5.0
	global_position = player.global_position + Vector2.RIGHT.rotated(angle) * RADIUS
	boss_cooldown -= delta
	for body in get_overlapping_bodies():
		if body.is_in_group("bosses"):
			if boss_cooldown <= 0:
				body.damage_boss(1)
				boss_cooldown = BOSS_COOLDOWN
		elif body.is_in_group("enemies"):
			body.die()
