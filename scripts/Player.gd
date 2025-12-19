extends CharacterBody2D

var movespeed = 200
var bullet = preload("res://scenes/bullett.tscn")
var bullet_rotation = 0

func _ready():
	pass
	
func _physics_process(_delta):
	var motion = Vector2()
	
	if Input.is_action_pressed("a"):
		motion.x -= 1
		$top.play('left')
	if Input.is_action_pressed("d"):
		motion.x += 1
		$top.play('right')
	if Input.is_action_pressed("w"):
		motion.y -= 1
		$top.play('up')
	if Input.is_action_pressed("s"):
		motion.y += 1
		$top.play('down')
		
	if Input.is_action_pressed("d") or Input.is_action_pressed("a") or Input.is_action_pressed("s") or Input.is_action_pressed("w"):
		$bottom.play("walk")
	else:
		$bottom.play("idle")
		$top.play('none')

	if Input.is_action_pressed("up"):
		$top.play('up')
	elif Input.is_action_pressed("left"):
		$top.play('left')
	elif Input.is_action_pressed("right"):
		$top.play('right')
	elif Input.is_action_pressed("down"):
		$top.play('down')
		
	motion = motion.normalized()
	velocity = motion * movespeed
	move_and_slide()
	if $Timer.is_stopped():
		if Input.is_action_pressed("up") and Input.is_action_pressed("right"):
			bullet_rotation = 315
		elif Input.is_action_pressed("up") and Input.is_action_pressed("left"):
			bullet_rotation = 225
		elif Input.is_action_pressed("down") and Input.is_action_pressed("left"):
			bullet_rotation = 135
		elif Input.is_action_pressed("down") and Input.is_action_pressed("right"):
			bullet_rotation = 45
		elif Input.is_action_pressed("left"):
			bullet_rotation = 180
		elif Input.is_action_pressed("right"):
			bullet_rotation = 0
		elif Input.is_action_pressed("up"):
			bullet_rotation = 270
		elif Input.is_action_pressed("down"):
			bullet_rotation = 90
		if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
			shoot()
			
func shoot():
	$Timer.start()
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = bullet_rotation
	get_tree().get_root().call_deferred("add_child",bullet_instance)
