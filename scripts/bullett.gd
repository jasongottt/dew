extends Area2D

var SPEED = 350

func _process(delta):
	$Sprite2D.rotation = -rotation
	var motion = Vector2(cos(self.rotation), sin(self.rotation)) * SPEED
	position += motion * delta


	

func _on_body_entered(body):
	queue_free()
