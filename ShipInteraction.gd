extends "res://Interaction.gd"


func can_interact(troop : Spatial) -> bool:
	return !owner.is_player_or_ai == 1 # si és una IA, que tmpc no pugui si hi ha una IA
	# and same equip


func interact(troop : Spatial) -> void: # : Troop
	owner.init(troop.pilot_man)
	# troop.get_node("HealthSystem").heal(10000)
