extends Gun


func _process(delta):
	shooting = Input.is_action_pressed("shoot")
	var cam := get_viewport().get_camera()
	var cam_basis : Basis = cam.global_transform.basis
	$RayCast.global_transform.origin = cam.global_transform.origin
	global_transform.basis = cam_basis.get_euler() + Vector3(deg2rad(180), 0, 0)
