extends Node2D

# a thin line around the sprite it's put on: the sprite drawn again one pixel
# left, right, up and down in a flat color, behind the sprite itself.
# the color is in outline.tscn

const STEPS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

func _process(_delta):
	# the sprite animates, so this follows it every frame
	queue_redraw()

func _draw():
	if not Game.outlines:
		return
	var sprite = get_parent()
	var texture = sprite.texture if sprite is Sprite2D else sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if texture == null:
		return
	var size = texture.get_size()
	var corner = sprite.offset - (size / 2 if sprite.centered else Vector2.ZERO)
	var flip = Vector2(-1 if sprite.flip_h else 1, -1 if sprite.flip_v else 1)
	for step in STEPS:
		draw_texture_rect(texture, Rect2(corner + step, size * flip), false)
