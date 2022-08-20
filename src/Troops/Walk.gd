extends OnGroundState


func update(delta):
	# Check input and change the direction
	var aim : Basis = owner.get_global_transform().basis
	direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	if Input.is_action_pressed("run") and aim.xform_inv(direction).z == 1: # > 0 ?
		emit_signal("finished", "run")
		return
	
	move(delta, MAX_SPEED, direction)
	
	update_walk_anim(delta)
