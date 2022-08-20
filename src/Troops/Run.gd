extends OnGroundState


func enter():
	#owner.running = true
	owner.can_shoot = false
	owner.get_node("AnimationTree").set("parameters/StateMachine/walk/move/3/blend_position", 1)


func update(delta):
	# Check input and change the direction
	var aim : Basis = owner.get_global_transform().basis
	direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	move(delta, MAX_SPEED, direction)
	if not Input.is_action_pressed("run") or aim.xform_inv(direction).z < 1: # <= 0?
		emit_signal("finished", "walk")
	
	update_walk_anim(delta)


func exit():
	# owner.running = false
	owner.can_shoot = true
	owner.get_node("AnimationTree").set("parameters/StateMachine/walk/move/3/blend_position", 0)
