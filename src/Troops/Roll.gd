extends MoveState

var roll_direction : Vector3

func enter():
	var aim : Basis = owner.get_global_transform().basis
	roll_direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	roll_direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	roll_direction.y = 0
	roll_direction = roll_direction.normalized()
	
	if !roll_direction: # potser q no hagi rpemut cal teclat, es a dir, no canvia de direcció
		roll_direction = aim.z
	# animació
	owner.get_node("Model").rotation.y = Vector2(roll_direction.z, roll_direction.x).angle()
	velocity = roll_direction * 25 # impuls
	
	owner.get_node("AnimationPlayer").play("Roll")


func update(delta):
	# La MAX_SPEED hauria de ser una corba 0.5-1-0 (al final q esperi uns segons per aixecar-se)
	# nse de moment així a miem fa el fet
	move(delta, MAX_SPEED, roll_direction)


func _on_animation_finished(anim_name):
	if anim_name == "Roll":
		emit_signal("finished", "walk")


func exit():
	velocity = Vector3(0, velocity.y, 0) # em penso q pot causar errors
	owner.get_node("Model").rotation.y = 0
