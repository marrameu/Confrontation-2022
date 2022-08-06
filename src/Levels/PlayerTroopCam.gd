extends InterpolatedCamera


export var cam_pos_path : NodePath


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if get_node_or_null(cam_pos_path):
		target = cam_pos_path
		translation = get_node(cam_pos_path).global_transform.origin
		rotation = get_node(cam_pos_path).global_transform.basis.get_euler()
