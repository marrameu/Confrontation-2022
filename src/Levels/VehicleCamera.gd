extends InterpolatedCamera


func _on_player_entered_vehicle(new_vehicle : Spatial):
	target = new_vehicle.get_node("%CameraPosition").get_path()
	translation = get_node(target).global_translation # rotació tmb?
	# vehicle.cam = self # no hauria de caldre
	enabled = true
	make_current()
