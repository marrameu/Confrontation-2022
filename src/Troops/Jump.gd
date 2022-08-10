extends MoveState


func enter():
	velocity.y = jump_height
	has_contact = false
	owner.move_and_slide(velocity, Vector3(0, 1, 0), false, 4, deg2rad(MAX_SLOPE_ANGLE))
	# si no fa move and slide immediatament, comprova si owner.is_on_floor() i comq si que hi és...
	# es podria fer una vairable per tal que en entrar a l'estat no comprovi res la primera vegada, però caldria editar el move i el MoveState


func update(delta):
	if has_contact and owner.is_on_floor():
		emit_signal("finished", "walk")
	
	var aim : Basis = owner.get_global_transform().basis
	var direction : Vector3 = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	move(delta, MAX_SPEED, direction)
