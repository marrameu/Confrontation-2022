extends "res://src/StateMachine/State.gd"
class_name AITroopState


func update_navigation_node():
	if owner.position.y < 1000:
		owner.get_node("PathMaker").navigation_node = get_node("/root/Level/Map/Node3D")
		owner.agent.set_navigation_map(owner.get_world_3d().navigation_map)
		#owner.get_parent().remove_child(owner)
		#owner.get_node("PathMaker").navigation_node.add_child(owner)
	else:
		var my_cap_ship = null
		var cap_ships = get_tree().get_nodes_in_group("CapitalShips")
		var new_cap_ship_pos := Vector3(INF, INF, INF)
		for cap_ship in cap_ships: # Com indic que ha de ser un Node3D? O un array de Spatials
			if owner.global_transform.origin.distance_to(cap_ship.global_transform.origin) <  owner.global_transform.origin.distance_to(new_cap_ship_pos):
				new_cap_ship_pos = cap_ship.global_transform.origin
				my_cap_ship = cap_ship
	
		if my_cap_ship:
			owner.get_node("PathMaker").navigation_node = my_cap_ship.get_node("Node3D")
			owner.agent.set_navigation_map(owner.get_world_3d().navigation_map)
			#owner.get_parent().remove_child(owner)
			#owner.get_node("PathMaker").navigation_node.add_child(owner)
		else:
			print("ERROR: No Capital Ships")


func _on_CheckCurrentEnemyTimer_timeout():
	if not get_parent().current_state == self:
		return
	
	# AITroopShooting.gd
	if owner.current_enemy:
		if not weakref(owner.current_enemy).get_ref():
			owner.current_enemy = null
			return
		var dist : float = owner.current_enemy.position.distance_to(owner.position)
		var ray = owner.get_world_3d().direct_space_state.intersect_ray(owner.position + Vector3(0, 1.75, 0), owner.current_enemy.position + Vector3(0, 1.75, 0), [owner, owner.current_enemy], 3) # sols environmmmment
		if ray:
			if dist > 500: # si és prou a prop, no és estùpid, sap checked s'amaga
				owner.current_enemy = null
			else:
				owner.wait_to_shoot = true
		else:
			owner.wait_to_shoot = false
