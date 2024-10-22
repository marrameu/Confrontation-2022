@tool
extends Node

## Exported variables
var flare_strength := 1.0 :
	get:
		return flare_strength # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_flare_strength
var flare_bias := 1.05 :
	get:
		return flare_bias # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_flare_bias
var flare_blur := 2.0 :
	get:
		return flare_blur # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_flare_blur

var distortion_quality := 0 :
	get:
		return distortion_quality # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_distortion_quality
var distortion := 2.0 :
	get:
		return distortion # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_flare_distortion

var ghost_count := 7 :
	get:
		return ghost_count # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_ghost_count
var ghost_spacing := 0.3 :
	get:
		return ghost_spacing # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_ghost_spacing
var halo_width := 0.25 :
	get:
		return halo_width # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_halo_width

var streak_strength := 0.5 :
	get:
		return streak_strength # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_streak_strength
var lens_dirt = preload("lens_dirt_default.jpeg") :
	get:
		return lens_dirt # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_lens_dirt
## Exported variables

var screen := MeshInstance3D.new()
var material := preload("lens_flare_shader.tres").duplicate()


func _get_property_list() -> Array:
	var properties := [
		{name="LensFlare", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY},
		{name="flare_strength", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="0,16"},
		{name="flare_bias", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="0,16"},
		{name="flare_blur", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="0,10"},
		{name="distortion_quality", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="Low,Medium,High"},
		{name="distortion", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="0,50"},
		{name="ghost_count", type=TYPE_INT, hint=PROPERTY_HINT_RANGE, hint_string="0,20"},
		{name="ghost_spacing", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="0,1"},
		{name="halo_width", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="0,1"},
		{name="streak_strength", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="0,1"},
		{name="lens_dirt", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Texture2D"},
	]
	
	return properties


func _init():
	screen.mesh = BoxMesh.new()
	screen.scale = Vector3(1,1,1) * pow(2.0,30);
	add_child(screen)
	screen.material_override = material


func _enter_tree() -> void:
	set_flare_strength(flare_strength)
	set_flare_bias(flare_bias)
	set_flare_distortion(distortion)
	set_distortion_quality(distortion_quality)
	set_ghost_count(ghost_count)
	set_ghost_spacing(ghost_spacing)
	set_halo_width(halo_width)
	set_streak_strength(streak_strength)
	set_flare_blur(flare_blur)
	set_lens_dirt(lens_dirt)


func set_flare_strength(value: float) -> void:
	flare_strength = value
	material.set_shader_parameter("bloom_scale", value)


func set_flare_bias(value: float) -> void:
	flare_bias = value
	material.set_shader_parameter("bloom_bias", value)


func set_flare_distortion(value: float) -> void:
	distortion = value
	material.set_shader_parameter("distort", value)


func set_distortion_quality(value: int) -> void:
	distortion_quality = value
	material.set_shader_parameter("distortion_quality", value)


func set_ghost_count(value: int) -> void:
	ghost_count = value
	material.set_shader_parameter("ghosts", value)


func set_ghost_spacing(value: float) -> void:
	ghost_spacing = value
	material.set_shader_parameter("ghost_dispersal", value)


func set_halo_width(value: float) -> void:
	halo_width = value
	material.set_shader_parameter("halo_width", value)


func set_streak_strength(value: float) -> void:
	streak_strength = value
	material.set_shader_parameter("streak_strength", value)


func set_flare_blur(value: float) -> void:
	flare_blur = value
	material.set_shader_parameter("lod", value)


func set_lens_dirt(value: Texture2D) -> void:
	lens_dirt = value
	material.set_shader_parameter("lens_dirt", value)
