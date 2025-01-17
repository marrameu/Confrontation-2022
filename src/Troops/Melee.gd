extends MoveState

var attack_direction

func enter():
	owner.can_shoot = false
	owner.can_rotate = false
	
	var aim : Basis = owner.get_global_transform().basis
	attack_direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	attack_direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	attack_direction.y = 0
	attack_direction = attack_direction.normalized()
	
	if attack_direction == Vector3.ZERO: # potser q no hagi rpemut cal teclat, es a dir, no canvia de direcció
		attack_direction = aim.z
	
	owner.get_node("Model").rotation.y = Vector2(attack_direction.z, attack_direction.x).angle() - owner.rotation.y
	# més endavant fer que no giri el model, sinó que tingui animació per a les 4 direccions
	
	owner.get_node("AnimationTree").get("parameters/StateMachine/playback").travel("punch")
	owner.get_node("AnimationPlayer").play("Melee")


func update(delta):
	# La MAX_SPEED hauria de ser una corba 0.5-1-0 (al final q esperi uns segons per aixecar-se)
	# nse de moment així a miem fa el fet
	move(delta, MAX_SPEED, attack_direction)


func _on_animation_finished(anim_name):
	if anim_name == "Melee":
		emit_signal("finished", "walk")


func exit():
	owner.can_shoot = true
	owner.can_rotate = true
	velocity = Vector3(0, velocity.y, 0) # em penso q pot causar errors
	owner.get_node("Model").rotation.y = 0


func impulse():
	velocity = attack_direction * 10 # impuls
