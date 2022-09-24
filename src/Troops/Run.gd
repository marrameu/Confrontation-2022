extends OnGroundState


func enter():
	#owner.running = true
	owner.can_shoot = false
	owner.get_node("AnimationTree").set("parameters/StateMachine/move/move/3/blend_position", 1)


func update(delta):
	# Check input and change the direction
	var aim : Basis = owner.get_global_transform().basis
	direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	move(delta, MAX_SPEED, direction)
	var ello := (direction * aim.z).z + (direction * aim.z).x + (direction * aim.z).y  #solucio de kk
	if not Input.is_action_pressed("run") or ello < 0.99: # <= 0?
		emit_signal("finished", "walk")
	
	owner.get_node("AnimationTree").set("parameters/StateMachine/move/Blend2/blend_amount", lerp(float(owner.get_node("AnimationTree").get("parameters/StateMachine/move/Blend2/blend_amount")), 0.0, 20 * delta))
	update_walk_anim(delta)


func exit():
	# owner.running = false
	owner.can_shoot = true
	owner.get_node("AnimationTree").set("parameters/StateMachine/move/move/3/blend_position", 0)
