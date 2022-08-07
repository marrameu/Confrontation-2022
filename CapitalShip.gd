extends "res://BigShip.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _ready():
	$SceneRoot/engines.material_override = blue_mat if blue_team else red_mat
	$SceneRoot/bottom.material_override = blue_mat if blue_team else red_mat
	$SceneRoot/up.material_override = blue_mat if blue_team else red_mat


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
