extends AITroopState


func enter():
	update_navigation_node()
	if owner.translation.y > 1500:
		emit_signal("finished", "enter_ship")
	else:
		emit_signal("finished", "conquer_ground_cps")
		if randi() % 5 == 2:
			emit_signal("finished", "enter_ship")
