extends MoveState


func enter() -> void:
	owner.get_node("AnimationTree").get("parameters/StateMachine/playback").travel("die")
	owner.can_aim = false
	owner.can_rotate = false
	owner.can_shoot = false
	owner.can_change_weapon = false
	owner.dead = true
