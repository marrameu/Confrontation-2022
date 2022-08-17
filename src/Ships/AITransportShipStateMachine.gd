extends "res://AIShipStateMachine.gd"


func set_states_map():
	states_map = {
		"choose_objective": $ChooseObjective,
		"attack_enemy": $AttackEnemy, # li dius l'enemic i l'ataca, en acabar de matar-lo, torna a l'objectiu (convindria un timer pq no shi passi massa estona)
		"defend_bs": $DefendBS, # roman als voltants de la seva nau capital -> attack enemy
		"attack_big_ship": $AttackBigShip,
		"patrol_middle_point": $PatrolMiddlePoint,
		"push_forward": $PushForward,
		"escape" : $Escape,
		"enter_cs" : $EnterCS # q tmb el podria psoar a la NewShip.tscn
		#"dead": $Dead
	}
