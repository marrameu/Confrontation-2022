extends "res://src/StateMachine/StateMachine.gd"


func _ready():
	# si no és el servidor que es desactivi l'state machine (active) o crear un estat Client
	states_map = {
		"choose_objective": $ChooseObjective,
		"conquer_ground_cps": $ConquerGroundCPs,
		"enter_ship": $EnterShip
	}
	set_active(true)


func _change_state(state_name):
	print(owner.name, " enters ", state_name)
	._change_state(state_name)
