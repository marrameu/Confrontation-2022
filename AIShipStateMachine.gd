extends "res://src/StateMachine/StateMachine.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	# si no és el servidor que es desactivi l'state machine (active) o crear un estat Client
	states_map = {
		"choose_objective": $ChooseObjective,
		"attack_enemy": $AttackEnemy, # li dius l'enemic i l'ataca, en acabar de matar-lo, torna a l'objectiu (convindria un timer pq no shi passi massa estona)
		"attack_cs": $AttackCS, # va a la nau capital enemiga i la dispara
		"defend_bs": $DefendBS, # roman als voltants de la seva nau capital -> attack enemy
		"attack_big_ship": $AttackBigShip,
		"patrol_middle_point": $PatrolMiddlePoint,
		"push_forward": $PushForward,
		"escape" : $Escape
		#"dead": $Dead
	}
	
	set_active(false)


func _process(_delta):
	# fer-ho amb senyals
	if owner.get_node("HealthSystem").health < 700 and current_state != states_map["escape"]:
		current_state.escape()
