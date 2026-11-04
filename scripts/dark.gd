extends ColorRect

# the dark on dark levels, see dark.tscn. the lights are still the usual
# PointLight2Ds (the player's, the mob's, flares, the muzzle flash) so you can
# size and color them in their scenes, but this draws them instead and they're
# switched off. keeps going while the level's paused or scrolling, like the gloom

# the shader has room for this many lights at once
const MOST_LIGHTS = 32

# whose flashbulb (and lightning) lights everything up
var player: Node2D

func _process(_delta):
	var spots = PackedVector2Array()
	var reach = PackedFloat32Array()
	var colors = PackedColorArray()
	var to_here = get_global_transform().affine_inverse()
	# from every level, so mid-scroll you light up both
	for light in get_tree().root.find_children("*", "PointLight2D", true, false):
		light.enabled = false
		if not light.is_visible_in_tree() or light.texture == null or spots.size() == MOST_LIGHTS:
			continue
		spots.append(to_here * light.global_position)
		reach.append(light.texture.get_width() / 2.0 * light.texture_scale * light.global_scale.x)
		colors.append(Color(light.color, light.energy))
	material.set_shader_parameter("light_count", spots.size())
	material.set_shader_parameter("light_spots", spots)
	material.set_shader_parameter("light_reach", reach)
	material.set_shader_parameter("light_colors", colors)
	material.set_shader_parameter("flash", player.whiteout if is_instance_valid(player) else 0.0)
