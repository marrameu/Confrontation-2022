extends VehicleShooting


func _process(delta):
	super(delta)


func update_can_shoots():
	if owner.landing_areas > 0:
		var ind : int = 0
		for can_shoot in can_shoots:
			can_shoots[ind] = false
			ind += 1
	else:
		super.update_can_shoots()
