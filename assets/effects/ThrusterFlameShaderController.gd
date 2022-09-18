@tool
extends Node3D


@export var Intensity = 0.5 :
	get:
		return Intensity # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_intensity
@export var Speed = 1.0
@export var Energy = 1.0
@export var TextureUniform2 : GradientTexture2D = GradientTexture2D.new()

var turbo_gradient : Gradient = preload("res://assets/effects/ThrusterFlameTurboGradient.tres")
var normal_gradient : Gradient = preload("res://assets/effects/ThrusterFlameGradient.tres")


func _ready():
	TextureUniform2.gradient = normal_gradient


func set_intensity(new_intensity):#no se porque no funciona pero bueno
	Intensity = new_intensity



func _process(delta):
	$MeshInstance3D.get_surface_override_material(0).set_shader_parameter("Intensity", Intensity)
	$MeshInstance2.get_surface_override_material(0).set_shader_parameter("Intensity", Intensity)
	
	$MeshInstance3D.get_surface_override_material(0).set_shader_parameter("Speed", Speed)
	$MeshInstance2.get_surface_override_material(0).set_shader_parameter("Speed", Speed)
	
	$MeshInstance3D.get_surface_override_material(0).set_shader_parameter("Energy", Energy)
	$MeshInstance2.get_surface_override_material(0).set_shader_parameter("Energy", Energy)
	
	$MeshInstance3D.get_surface_override_material(0).set_shader_parameter("TextureUniform2", TextureUniform2)
