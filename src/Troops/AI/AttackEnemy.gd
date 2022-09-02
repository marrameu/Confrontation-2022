extends AITroopState

var approaching_enemy := false

func enter():
	approach_enemy()


func approach_enemy() -> void:
	approaching_enemy = true
	var begin : Vector3 = owner.get_node("PathMaker").navigation_node.get_closest_point(owner.get_translation())
	var end : Vector3 = owner.get_node("PathMaker").navigation_node.get_closest_point(owner.current_enemy.get_translation())
	owner.agent.set_target_location(end)


func _on_CheckCurrentEnemyTimer_timeout():
	if not get_parent().current_state == self:
		return
	._on_CheckCurrentEnemyTimer_timeout()
	if not owner.current_enemy:
		emit_signal("finished", "previous")
		return
	var ray = owner.get_world().direct_space_state.intersect_ray(owner.translation + Vector3(0, 1.75, 0), owner.current_enemy.translation + Vector3(0, 1.75, 0), [owner, owner.current_enemy], 3) # sols environmmmment
	if ray: # q passaria si la distància fos 1500 i no hi haguès raycast?
		if not approaching_enemy:
			approach_enemy()
		return
	var dist = owner.translation.distance_to(owner.current_enemy.translation)
	if dist < 200:
		
		approaching_enemy = false
		if dist < 50:
			# tira enrere
			owner.agent.set_target_location(owner.translation)
			#owner.get_node("PathMaker").clean_path()
			return
		else:
			# q es mougui de dreta a esquerra?, així els raycast pdorien obviar el layer de les tropes
			owner.agent.set_target_location(owner.translation)
			return
	
	# dsitància 200-500
	emit_signal("finished", "previous")
