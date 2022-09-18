extends AITroopState

var desired_ship : Ship

func enter():
	search_ship()


func update(delta):
	if weakref(desired_ship).get_ref():
		if desired_ship.is_player_or_ai != 0:
			emit_signal("finished", "enter_ship")


func search_ship(): # comprovar que no hi hagi ningú a la nau
	"""
	L'inici és get_closest_point de la posició local de la tropa respete el node de navegació.
	Tant l'inici com el final han de ser coordenades locals respecte el node de navegació.
	"""
	#var wr = weakref(owner.get_node("PathMaker").navigation_node)
	#if !wr.get_ref():
	#	#mor
	#	return
	
	#var begin : Vector3 = owner.get_node("PathMaker").navigation_node.get_closest_point(owner.global_transform.origin) # s'ha de fer amb la pos. global de la tropa pq, si no, malament rai
	# get_Closest_point perquè no es passi
	var end := Vector3.ZERO #$PathMaker.navigation_node.get_closest_point(begin + Vector3(randf_range(-200, 200), 0, randf_range(-200, 200)))
	
	
	if weakref(desired_ship).get_ref():
		if desired_ship.is_player_or_ai == 0:
			return
		desired_ship = null
	else:
		var ships = get_tree().get_nodes_in_group("Ships")
		var new_ship_pos : Vector3 = Vector3.INF
		for ship in ships:
			if ship.is_player_or_ai == 0:
				if owner.global_transform.origin.distance_to(ship.global_transform.origin) < owner.global_transform.origin.distance_to(new_ship_pos):
					if owner.get_node("PathMaker").navigation_node.get_closest_point(ship.global_transform.origin).distance_to(ship.global_transform.origin) < 30:
						new_ship_pos = ship.global_transform.origin
						desired_ship = ship
		if not weakref(desired_ship).get_ref():
			$WaitTimer.start()
		else:
			end = owner.get_node("PathMaker").navigation_node.get_closest_point(desired_ship.global_transform.origin)
			owner.agent.set_target_location(end)


func _on_NavigationAgent_target_reached():
	if get_parent().current_state != self:
		return
	
	if not weakref(desired_ship).get_ref():
		emit_signal("finished", "enter_ship")
	else:
		if desired_ship.get_node("Interaction").can_interact(owner):
			desired_ship.get_node("Interaction").interact(owner)
			owner.queue_free()
		#else:
		#	emit_signal("finished", "enter_ship")


func _on_WaitTimer_timeout():
	search_ship()


func _on_CheckCurrentEnemyTimer_timeout() -> void:
	if not get_parent().current_state == self:
		return
	super._on_CheckCurrentEnemyTimer_timeout()
	if owner.current_enemy: # ha de calcular dues veagdes la distància, tot plegat es podria fer millor
		if owner.position.distance_to(owner.current_enemy.position) < 150:
			emit_signal("finished", "attack_enemy")

