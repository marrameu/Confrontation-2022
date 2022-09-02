extends VehicleShooting


func update_can_shoots():
	if owner.landing_areas > 0:
		var ind : int = 0
		for can_shoot in can_shoots:
			can_shoots[ind] = false
			ind += 1
	else:
		.update_can_shoots()
