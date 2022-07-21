extends Camera


export var cam_pos_path : NodePath


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	translation = get_node(cam_pos_path).global_transform.origin # lerp com la space cam
	rotation = get_node(cam_pos_path).global_transform.basis.get_euler()
