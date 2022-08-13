extends Spatial


export var granade_scene : PackedScene = preload("res://src/Troops/Weapons/Granade.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_just_pressed("special_weapon"):
		launch_granade()


func launch_granade():
	var new_granade : RigidBody = granade_scene.instance()
	new_granade.rotation = get_viewport().get_camera().global_rotation
	get_tree().current_scene.add_child(new_granade)
	new_granade.translation = owner.translation
