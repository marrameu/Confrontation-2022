extends Control


var true_self : Node3D = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if weakref(true_self).get_ref():
		# x: -4000 = 0, 4000 = 1920
		var scaled_pos := Vector2(true_self.position.x, true_self.position.z) * 0.24
		position =  scaled_pos + Vector2(960, 540) # - size/2 
		rotation = -true_self.rotation_degrees.y
	else:
		queue_free()
