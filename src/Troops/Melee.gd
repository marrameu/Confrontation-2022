extends MoveState

var attack_direction

func enter():
	owner.can_shoot = false
	owner.can_rotate = false
	var aim : Basis = owner.get_global_transform().basis
	attack_direction = aim.z
	
	attack_direction.y = 0

	# animació
	velocity = attack_direction * 5 # impuls
	
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
