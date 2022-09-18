extends "res://Interaction.gd"


func can_interact(troop : Node3D) -> bool:
	return ((owner.m_team == 2 and troop.blue_team) or (owner.m_team == 1 and not troop.blue_team))


func interact(troop : Node3D) -> void: # : Troop
	troop.get_node("HealthSystem").heal(10000)
	troop.shooting.fill_all_weapons()
