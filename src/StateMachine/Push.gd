extends "AIShipState.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update(_delta):
	return
	var push := 0.0
	push = -200 if owner.blue_team else 200
	owner.input.target = Vector3()
