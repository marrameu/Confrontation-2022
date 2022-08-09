extends "res://src/StateMachine/State.gd"
class_name AITroopState


func update_navigation_node():
	if owner.translation.y < 1000:
		owner.get_node("PathMaker").navigation_node = get_node("/root/Level/Map/Navigation")
	else:
		var my_cap_ship = null
		var cap_ships = get_tree().get_nodes_in_group("CapitalShips")
		var new_cap_ship_pos : Vector3 = Vector3.INF
		for cap_ship in cap_ships: # Com indic que ha de ser un Spatial? O un array de Spatials
			if owner.global_transform.origin.distance_to(cap_ship.global_transform.origin) <  owner.global_transform.origin.distance_to(new_cap_ship_pos):
				new_cap_ship_pos = cap_ship.global_transform.origin
				my_cap_ship = cap_ship
	
		if my_cap_ship:
			owner.get_node("PathMaker").navigation_node = my_cap_ship.get_node("Navigation")
		else:
			print("ERROR: No Capital Ships")
