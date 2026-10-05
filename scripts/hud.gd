extends CanvasLayer

func _process(_delta):
	var level = get_parent()
	var player = level.get_node("Player")
	$TimeBar.scale.x = max(level.time_left, 0) / level.wave_time
	$Whiteout.color.a = player.whiteout
	$Fog.visible = player.has_effect("fog")
	$Fog.material.set_shader_parameter("center", player.global_position)
	$Lives/Count.text = "x" + str(Game.lives)
	$Coins/Count.text = "x" + str(Game.coins)
	if Game.held_item == "":
		$Item/Icon.texture = null
	else:
		$Item/Icon.texture = load("res://sprites/items/%s.png" % Game.held_item)

	if Input.is_action_just_pressed("pause") and not level.frozen:
		get_tree().paused = not get_tree().paused
		$Paused.visible = get_tree().paused
