extends Control


var true_self : Spatial = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if weakref(true_self).get_ref():
		# x: -4000 = 0, 4000 = 1920
		var scaled_pos := Vector2(true_self.translation.x, true_self.translation.z) * 0.24
		rect_position =  scaled_pos + Vector2(960, 540) # - rect_size/2 
		rect_rotation = -true_self.rotation_degrees.y
	else:
		queue_free()
