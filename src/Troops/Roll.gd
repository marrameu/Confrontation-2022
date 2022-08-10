extends MoveState

var roll_direction : Vector3

func enter():
	var aim : Basis = owner.get_global_transform().basis
	roll_direction = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	roll_direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	roll_direction.y = 0
	roll_direction = roll_direction.normalized()
	
	velocity += roll_direction * 20
	
	$Timer.start()


func update(delta):
	move(delta, MAX_SPEED, roll_direction)


func _on_Timer_timeout(): # en lloc de timer -> animació
	emit_signal("finished", "walk")


func exit():
	# velocity = 0?
	pass
