extends "res://Interaction.gd"


func can_interact(troop : Node3D) -> bool:
	return !owner.is_player_or_ai == 1 # si és una IA, que tmpc no pugui si hi ha una IA
	# and same equip


func interact(troop : Node3D) -> void: # : Troop
	owner.init(troop.pilot_man)
	# troop.get_node("HealthSystem").heal(10000)
