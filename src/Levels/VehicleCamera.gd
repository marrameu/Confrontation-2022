extends Camera3D


func _on_player_entered_vehicle(new_vehicle : Node3D):
	target = new_vehicle.get_node("%CameraPosition").get_path()
	position = get_node(target).global_translation # rotació tmb?
	# vehicle.cam = self # no hauria de caldre
	enabled = true
	make_current()


func _physics_process(delta):
	var zooming := Input.is_action_pressed("zoom") # and not ship.input.turboing
	if zooming:
		fov = lerp(fov, 40, .15)
	else:
		 #zooming = false TF?
		fov = lerp(fov, 70, .15)
