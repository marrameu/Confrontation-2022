extends Spatial


export var granade_scene : PackedScene = preload("res://src/Troops/Weapons/Granade.tscn")
export var label_path : NodePath
onready var label : Label = get_node(label_path)

export var MAX_AMMO : int = 3
var ammo := MAX_AMMO

export var fire_rate := 0.5
var _next_time_to_fire := 0.0
var time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	time += delta
	
	if Input.is_action_just_pressed("special_weapon") and time >= _next_time_to_fire:
		if ammo >= 1:
			_next_time_to_fire = time + 1.0 / fire_rate
			launch_granade()
		else:
			$NoAmmo.play()
	label.text = str(ammo)


func launch_granade():
	ammo -= 1
	var new_granade : RigidBody = granade_scene.instance()
	new_granade.rotation = get_viewport().get_camera().global_rotation
	get_tree().current_scene.add_child(new_granade)
	new_granade.translation = owner.translation
	$Throw.play()
