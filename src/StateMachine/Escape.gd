extends "AIShipState.gd"

var target_support_ship

func enter():
	# turbo, si en té
	owner.input.wants_turbo = true
	var clos_dist := INF
	for support_ship in get_tree().get_nodes_in_group("SupportShips"):
		if support_ship.blue_team == owner.pilot_man.blue_team:
			var dist = support_ship.translation.distance_to(owner.translation)
			if dist < clos_dist:
				target_support_ship = support_ship
				clos_dist = dist
	
	if not target_support_ship:
		print("malament rayo")


func update(_delta):
	owner.input.target = target_support_ship.get_node("SupportArea").global_transform.origin
	owner.input.wants_turbo = owner.translation.distance_to(owner.input.target) > 700
	if owner.get_node("HealthSystem").health > 700:
		emit_signal("finished", "choose_objective")
