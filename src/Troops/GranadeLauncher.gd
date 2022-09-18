extends Node3D


@export var granade_scene : PackedScene = preload("res://src/Troops/Weapons/Granade.tscn")

@export var MAX_AMMO : int = 3
var ammo := MAX_AMMO

@export var fire_rate := 0.5
var _next_time_to_fire := 0.0
var time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	time += delta


func launch_granade():
	ammo -= 1
	var new_granade : RigidBody3D = granade_scene.instantiate()
	new_granade.rotation = get_viewport().get_camera_3d().global_rotation
	get_tree().current_scene.add_child(new_granade)
	new_granade.position = owner.position
	$Throw.play()


func can_throw() -> bool:
	if time >= _next_time_to_fire:
		if ammo >= 1:
			_next_time_to_fire = time + 1.0 / fire_rate
			return true
		else:
			$NoAmmo.play()
	return false
