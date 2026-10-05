extends Area2D

@export var kind = "coin"
@export var lifetime := 10.0

func _ready():
	$Sprite2D.texture = load("res://sprites/items/%s.png" % kind)

func _process(delta):
	lifetime -= delta
	if lifetime < 3:
		visible = fmod(lifetime, 0.3) > 0.15
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("pick_up"):
		body.pick_up(kind)
		queue_free()
