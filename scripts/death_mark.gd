extends Node2D

@export var lifetime := 10

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()
