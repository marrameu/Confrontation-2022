extends OnGroundState


func update(delta):
	# Check input and change the direction
	var aim : Basis = owner.get_global_transform().basis
	direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	var ello := (direction * aim.z).z + (direction * aim.z).x + (direction * aim.z).y  #solucio de kk
	if not Input.is_action_pressed("crouch"): # <= 0?
		emit_signal("finished", "walk")
	
	move(delta, MAX_SPEED, direction)
	
	update_walk_anim(delta)


func update_walk_anim(delta) -> void:
	owner.get_node("AnimationTree").set("parameters/StateMachine/walk/Blend2/blend_amount", lerp(owner.get_node("AnimationTree").get("parameters/StateMachine/walk/Blend2/blend_amount"), 1.0, 20 * delta))
	var walk := Vector2(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"), Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	print(walk)
	owner.get_node("AnimationTree").set("parameters/StateMachine/walk/crouch/blend_position", lerp(owner.get_node("AnimationTree").get("parameters/StateMachine/walk/crouch/blend_position"), walk, 20 * delta))
