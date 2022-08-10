extends OnGroundState


func enter():
	owner.running = true


func update(delta):
	# Check input and change the direction
	var aim : Basis = owner.get_global_transform().basis
	var direction : Vector3 = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	move(delta, MAX_SPEED, direction)
	if not Input.is_action_pressed("run"):
		emit_signal("finished", "walk")


func exit():
	owner.running = false
