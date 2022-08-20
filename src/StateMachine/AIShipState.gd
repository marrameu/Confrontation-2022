tool
extends "res://src/StateMachine/State.gd"

var my_team_big_ships_wo_shields : Array
var enemy_big_ships_wo_shields : Array


func _get_configuration_warning() -> String:
	var warning := ""
	if owner != Ship:
		warning = "L''owner' de l'estat no és una nau"
	return warning


func escape():
	emit_signal("finished", "escape")


func closest_enemy(min_dist : float = 750.0) -> Ship:
	var clos_dist := min_dist
	var clos_enemy : Ship
	for ship in get_tree().get_nodes_in_group("Ships"):
		if ship.pilot_man:
			if ship.blue_team != owner.blue_team:
				var dist = owner.translation.distance_to(ship.translation)
				if dist < clos_dist:
					clos_dist = dist
					clos_enemy = ship
	
	return clos_enemy


func closest_enemy_to_cs(plus_dist : float = 500.0) -> Ship:
	var own_cs : Spatial = get_node_or_null("/root/Level/BigShips/CapitalShipBlue") if owner.blue_team else get_node_or_null("/root/Level/BigShips/CapitalShipRed")
	if not own_cs:
		return null
	var closest_dsit : float = owner.translation.distance_to(own_cs.translation) + plus_dist
	var clos_enemy : Ship
	for ship in get_tree().get_nodes_in_group("Ships"):
		if ship.pilot_man:
			if ship.blue_team != owner.blue_team:
				var dist = ship.translation.distance_to(own_cs.translation)
				if dist < closest_dsit:
					closest_dsit = dist
					clos_enemy = ship
	
	return clos_enemy


func closest_big_ship(type : String):
	# var own_cs : Spatial = get_node("/root/Level/BigShips/CapitalShipBlue") if owner.blue_team else get_node("/root/Level/BigShips/CapitalShipRed")
	var closest_dsit := INF
	var clos_enemy : Spatial
	for ship in get_tree().get_nodes_in_group(type):
		if ship.blue_team != owner.blue_team:
			var dist = ship.translation.distance_to(owner.translation)
			if dist < closest_dsit:
				closest_dsit = dist
				clos_enemy = ship
	
	return clos_enemy


func number_of_enemy_ships() -> int:
	var num : int = 0
	for ship in get_tree().get_nodes_in_group("Ships"):
		if ship.pilot_man:
			if ship.blue_team != owner.blue_team:
				num += 1
	return num


func number_of_my_team_ships() -> int:
	var num : int = 0
	for ship in get_tree().get_nodes_in_group("Ships"):
		if ship.pilot_man:
			if ship.blue_team == owner.blue_team:
				num += 1
	return num


func _on_big_ship_shields_down(ship):
	if not owner.pilot_man:
		return
	if ship.blue_team == owner.blue_team:
		my_team_big_ships_wo_shields.append(ship)
	else:
		enemy_big_ships_wo_shields.append(ship)


func clean_bigships_w_shields(ships_array) -> Array:
	var pos : int = 0
	while pos < ships_array.size():
		var remove := false
		if not ships_array[pos]:
			remove = true
		elif not weakref(ships_array[pos]).get_ref():
			remove = true
		elif ships_array[pos].get_node("HealthSystem").shield:
			remove = true
		if remove:
			ships_array.remove(pos)
			pos -= 1
		pos += 1
	return ships_array
