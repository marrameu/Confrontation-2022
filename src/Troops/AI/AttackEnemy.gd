extends AITroopState

var approaching_enemy := false

func enter():
	approach_enemy()


func approach_enemy() -> void:
	approaching_enemy = true
	var begin : Vector3 = NavigationServer3D.map_get_closest_point(owner.get_world_3d().navigation_map, (owner.get_position()))
	var end : Vector3 = NavigationServer3D.map_get_closest_point(owner.get_world_3d().navigation_map, (owner.current_enemy.get_position()))
	owner.agent.set_target_location(end)


func _on_CheckCurrentEnemyTimer_timeout():
	if not get_parent().current_state == self:
		return
	super._on_CheckCurrentEnemyTimer_timeout()
	if not owner.current_enemy:
		emit_signal("finished", "previous")
		return
	var ray = owner.get_world_3d().direct_space_state.intersect_ray(owner.position + Vector3(0, 1.75, 0), owner.current_enemy.position + Vector3(0, 1.75, 0), [owner, owner.current_enemy], 3) # sols environmmmment
	if ray: # q passaria si la distància fos 1500 i no hi haguès raycast?
		if not approaching_enemy:
			approach_enemy()
		return
	var dist = owner.position.distance_to(owner.current_enemy.position)
	if dist < 200:
		
		approaching_enemy = false
		if dist < 50:
			# tira enrere
			owner.agent.set_target_location(owner.position)
			#owner.get_node("PathMaker").clean_path()
			return
		else:
			# q es mougui de dreta a esquerra?, així els raycast pdorien obviar el layer de les tropes
			owner.agent.set_target_location(owner.position)
			return
	
	# dsitància 200-500
	emit_signal("finished", "previous")
