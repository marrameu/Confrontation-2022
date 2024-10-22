extends "res://src/StateMachine/StateMachine.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	states_map = {
		"walk": $Walk,
		"run": $Run,
		"crouch": $Crouch,
		"jump": $Jump,
		"roll": $Roll,
		"melee": $Melee,
		"reload": $Reload,
		"dead": $Dead,
		"throw_grenade": $ThrowGrenade
	}
	active = false


func _change_state(state_name):
	print(state_name)
	if not active:
		return
	if states_map[state_name] is MoveState and current_state is MoveState:
		states_map[state_name].initialize(current_state.velocity)
	if state_name == "jump" and current_state is MoveState:
		$Jump.MAX_SPEED = current_state.MAX_SPEED
	super._change_state(state_name)
