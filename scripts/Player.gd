extends CharacterBody2D

signal died

@export var movespeed = 200
# seconds between shots, before gun upgrades
@export var shoot_delay = 0.35
# how long the muzzle flash shows for each shot
@export var muzzle_flash_time = 0.05

var bullet = preload("res://scenes/bullett.tscn")
var bullet_rotation = 0
var invincible = false
var flash_left = 0.0
var effects = {}
# 1 is a fully white screen, fades back to 0 over a second
var whiteout = 0.0

func _ready():
	pass
	
func _physics_process(delta):
	for effect in effects.keys():
		effects[effect] -= delta
		if effects[effect] <= 0:
			effects.erase(effect)
	whiteout = max(whiteout - delta, 0)
	flash_left -= delta
	$MuzzleFlash.visible = flash_left > 0
	if has_effect("whiskey"):
		modulate = Color(1, 0.8, 0.5)
	elif has_effect("trench_coat"):
		modulate = Color(0.8, 0.7, 0.6)
	else:
		modulate = Color(1, 1, 1)

	if Input.is_action_just_pressed("use") and Game.held_item != "":
		var item = Game.held_item
		Game.held_item = ""
		$Powerups.use(item)

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
	if has_effect("whiskey"):
		velocity = velocity.lerp(motion * current_speed(), 0.08)
	else:
		velocity = motion * current_speed()
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

	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			take_hit()
			break

func shoot():
	$Timer.start(fire_delay())
	var angles = [bullet_rotation]
	if has_effect("sawed_off"):
		angles = [bullet_rotation - 30, bullet_rotation - 15, bullet_rotation, bullet_rotation + 15, bullet_rotation + 30]
	for angle in angles:
		var bullet_instance = bullet.instantiate()
		bullet_instance.position = get_global_position()
		bullet_instance.rotation_degrees = angle
		bullet_instance.damage = 1 + Game.ammo
		get_parent().call_deferred("add_child",bullet_instance)

	# flash at the end of the gun, it lights things up on dark levels
	$MuzzleFlash.position = Vector2.RIGHT.rotated(deg_to_rad(bullet_rotation)) * 24
	$MuzzleFlash/PointLight2D.visible = get_parent().get("dark") == true
	$MuzzleFlash.visible = true
	flash_left = muzzle_flash_time

func has_effect(effect):
	return effects.has(effect)

func current_speed():
	var speed = movespeed * (1 + 0.2 * Game.boots)
	if has_effect("coffee"):
		speed *= 1.5
	if has_effect("trench_coat"):
		speed *= 0.8
	return speed

func fire_delay():
	return shoot_delay - 0.05 * Game.gun

# coins and lives are used right away, anything else goes in the held slot,
# or gets used straight away if the slot is already full
func pick_up(kind):
	if kind == "coin":
		Game.coins += 1
	elif kind == "coin5":
		Game.coins += 5
	elif kind == "life":
		Game.lives += 1
	elif Game.held_item == "":
		Game.held_item = kind
	else:
		$Powerups.use(kind)

# anything that can hurt the player goes through here
func take_hit():
	if invincible or has_effect("whiskey"):
		return
	if has_effect("trench_coat"):
		effects.erase("trench_coat")
		blink()
		return
	die()

func die():
	invincible = true
	died.emit()

func respawn():
	blink()

func blink():
	invincible = true
	for i in 10:
		visible = not visible
		await get_tree().create_timer(0.15).timeout
	visible = true
	invincible = false
