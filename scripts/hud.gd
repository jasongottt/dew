extends CanvasLayer

func _process(_delta):
	var level = get_parent()
	var player = level.get_node("Player")
	# the top bar is the clock, or the boss's health in a boss fight
	var bar = max(level.time_left, 0) / level.wave_time
	if level.boss_scene:
		bar = 0.0
		if is_instance_valid(level.boss):
			bar = max(level.boss.health, 0) / float(level.boss.max_health)
	$TimeBar.scale.x = bar
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
