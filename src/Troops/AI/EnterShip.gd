extends AITroopState

var desired_ship : Ship
var wait := false


func enter():
	search_ship()


func update(delta):
	if weakref(desired_ship).get_ref():
		if desired_ship.is_player_or_ai != 0:
			emit_signal("finished", "enter_ship")


func search_ship(): # comprovar que no hi hagi ningú a la nau
	var searching_ship = true
	
	"""
	L'inici és get_closest_point de la posició local de la tropa respete el node de navegació.
	Tant l'inici com el final han de ser coordenades locals respecte el node de navegació.
	"""
	var wr = weakref(owner.get_node("PathMaker").navigation_node)
	if !wr.get_ref():
		#mor
		return
	
	var begin : Vector3 = owner.get_node("PathMaker").navigation_node.get_closest_point(owner.global_transform.origin) # s'ha de fer amb la pos. global de la tropa pq, si no, malament rai
	# get_Closest_point perquè no es passi
	var end := Vector3.ZERO #$PathMaker.navigation_node.get_closest_point(begin + Vector3(rand_range(-200, 200), 0, rand_range(-200, 200)))
	
	var choosen_ship : Ship = null
	var ships = get_tree().get_nodes_in_group("Ships")
	var new_ship_pos : Vector3 = Vector3.INF
	for ship in ships: # què fer si no hi ha ships?
		if owner.global_transform.origin.distance_to(ship.global_transform.origin) < owner.global_transform.origin.distance_to(new_ship_pos):
			if ship.is_player_or_ai == 0:
				new_ship_pos = ship.global_transform.origin
				desired_ship =  ship
	if desired_ship:
		var closest_point_to_ship : Vector3 = owner.get_node("PathMaker").navigation_node.get_closest_point(new_ship_pos)
		if closest_point_to_ship.distance_to(new_ship_pos) < 15:
			end = closest_point_to_ship
		else:
			$WaitTimer.start()
	else:
		$WaitTimer.start()
	
	owner.get_node("PathMaker").update_path(begin, end)


func _on_PathMaker_arrived():
	if not weakref(desired_ship).get_ref():
		emit_signal("finished", "enter_ship")
	elif desired_ship.is_player_or_ai == 0:
		desired_ship.init(owner.pilot_man)
		owner.queue_free()


func _on_WaitTimer_timeout():
	search_ship()
