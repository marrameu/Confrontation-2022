extends Button


var cp : CommandPost


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not is_visible_in_tree():
		return # no calen els calculs
	if cp and weakref(cp).get_ref():
		rect_position = get_viewport().get_camera().unproject_position(cp.translation)
		rect_position -= Vector2(rect_size.x / 2, rect_size.y / 2)
	#else:
	#	queue_free()
