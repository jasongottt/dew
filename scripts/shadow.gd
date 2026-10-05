extends "res://scripts/basic_enemy.gd"

var dark := false

func _ready():
	super()
	dark = get_parent().get("dark") == true
	if dark:
		# only shows up where something is lighting it
		var light_only = CanvasItemMaterial.new()
		light_only.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
		$AnimatedSprite2D.material = light_only
	else:
		$AnimatedSprite2D.modulate.a = 0.35

func _process(_delta):
	# the flashbulb lights everything, shadows included
	if dark and player:
		var flash = player.whiteout > 0.3
		$AnimatedSprite2D.material.light_mode = CanvasItemMaterial.LIGHT_MODE_NORMAL if flash else CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
