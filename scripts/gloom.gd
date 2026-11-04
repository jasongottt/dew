extends ColorRect

# darker the farther you are from the player, over the whole level.
# how dark and how far is in gloom.tscn. it keeps up even while the level
# is paused or scrolling (see Game.scroll_to)

var follow: Node2D

func _process(_delta):
	if follow:
		material.set_shader_parameter("centre", get_global_transform().affine_inverse() * follow.global_position)
