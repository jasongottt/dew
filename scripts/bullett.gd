extends Area2D

var SPEED = 350
var damage = 1

func _process(delta):
	$Sprite2D.rotation = -rotation
	var motion = Vector2(cos(self.rotation), sin(self.rotation)) * SPEED
	position += motion * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.dead:
			return
		var health = body.health
		body.hit(damage)
		# upgraded ammo keeps going with whatever damage is left over
		damage -= health
		if damage > 0:
			return
	queue_free()
