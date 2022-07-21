tool
extends Spatial


export var Intensity = 0.5 setget set_intensity
export var Speed = 1.0
export var Energy = 1.0
export var TextureUniform2 : GradientTexture = GradientTexture.new()

var turbo_gradient : Gradient = preload("res://assets/effects/ThrusterFlameTurboGradient.tres")
var normal_gradient : Gradient = preload("res://assets/effects/ThrusterFlameGradient.tres")


func _ready():
	TextureUniform2.gradient = normal_gradient


func set_intensity(new_intensity):#no se porque no funciona pero bueno
	Intensity = new_intensity



func _process(delta):
	$MeshInstance.get_surface_material(0).set_shader_param("Intensity", Intensity)
	$MeshInstance2.get_surface_material(0).set_shader_param("Intensity", Intensity)
	
	$MeshInstance.get_surface_material(0).set_shader_param("Speed", Speed)
	$MeshInstance2.get_surface_material(0).set_shader_param("Speed", Speed)
	
	$MeshInstance.get_surface_material(0).set_shader_param("Energy", Energy)
	$MeshInstance2.get_surface_material(0).set_shader_param("Energy", Energy)
	
	$MeshInstance.get_surface_material(0).set_shader_param("TextureUniform2", TextureUniform2)
