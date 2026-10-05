extends Area2D

var direction = Vector2.RIGHT
var speed = 160.0

func _physics_process(delta):
	# hangs in the air while the flashbulb has everyone frozen
	var player = get_parent().get_node_or_null("Player")
	if player and player.has_effect("flashbulb"):
		return
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_hit"):
		body.take_hit()
	queue_free()
