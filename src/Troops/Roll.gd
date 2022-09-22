extends MoveState

var roll_direction : Vector3

func enter():
	owner.can_shoot = false
	owner.can_rotate = false
	
	var aim : Basis = owner.get_global_transform().basis
	roll_direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	roll_direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	roll_direction.y = 0
	roll_direction = roll_direction.normalized()
	
	if roll_direction == Vector3.ZERO: # potser q no hagi rpemut cal teclat, es a dir, no canvia de direcció
		roll_direction = aim.z
	# animació
	owner.get_node("Model").rotation.y = Vector2(roll_direction.z, roll_direction.x).angle() - owner.rotation.y
	
	owner.get_node("AnimationPlayer").play("Roll")
	owner.get_node("AnimationTree").get("parameters/StateMachine/playback").travel("roll")


func update(delta):
	# La MAX_SPEED hauria de ser una corba 0.5-1-0 (al final q esperi uns segons per aixecar-se)
	# nse de moment així a miem fa el fet
	move(delta, MAX_SPEED, roll_direction)


func _on_animation_finished(anim_name):
	if anim_name == "Roll":
		emit_signal("finished", "walk")


func exit():
	owner.can_shoot = true
	owner.can_rotate = true
	velocity = Vector3(0, velocity.y, 0) # em penso q pot causar errors
	owner.get_node("Model").rotation.y = 0


func impulse():
	velocity = roll_direction * 25 + Vector3(0, 10, 0)
