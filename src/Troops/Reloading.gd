extends OnGroundState


func enter():
	$Reload.play()
	owner.can_shoot = false
	owner.can_change_weapon = false
	owner.get_node("AnimationTree").set("parameters/StateMachine/walk/reload/active", true)
	owner.get_node("AnimationPlayer").play("Reload")


func update(delta):
	# Check input and change the direction
	var aim : Basis = owner.get_global_transform().basis
	direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	move(delta, MAX_SPEED, direction)
	
	update_walk_anim(delta)


func handle_input(event : InputEvent):
	return

func exit():
	owner.can_change_weapon = true
	owner.can_shoot = true


func _on_animation_finished(anim_name):
	if anim_name == "Reload":
		emit_signal("finished", "walk")
