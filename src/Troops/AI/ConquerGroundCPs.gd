extends AITroopState

# terra
var idle := false
var going_to_cp_to_conquer := false
var conquering_a_cp := false


func enter():
	search_cp_and_conquer()


func _on_PathMaker_arrived():
	idle = false # nse q ve a compondre això
	
	if not conquering_a_cp:
		if not going_to_cp_to_conquer:
			search_cp_and_conquer()
		else: # vol dir que ja ha arribat al CP
			conquering_a_cp = true
			going_to_cp_to_conquer = false
			if ($ConquestTimer as Timer).is_stopped(): # aquesta comprovació es podria obviar
				$ConquestTimer.wait_time = rand_range(7.0, 13.0)
				# millor, en lloc de temps, senyal quan s'ha conquerit
				$ConquestTimer.start() # SI MOR CONQUERINT, REPAEREIX CONQUERINT? AL DISABLE CCOMPONENTS S'HAURIA DE RESTABLIR TMB


func search_cp_and_conquer(): # àlies terra
	# Update Path: Command Posts
	# Cercar els CP enemics
	var enemy_command_posts := []
	for command_post in get_tree().current_scene.get_node("%CommandPosts").get_children(): # get_tree().get_nodes_in_group("CommandPosts"): així no pq tmb busca els de les cs
		if command_post.capturable:
			if command_post.m_team == 0 or (command_post.m_team == 1 and owner.pilot_man.blue_team) or (command_post.m_team == 2 and not owner.pilot_man.blue_team):
				enemy_command_posts.push_back(command_post)
	
	# Hi ha CP
	if enemy_command_posts.size() > 0:
		going_to_cp_to_conquer = true
		
		var nearest_command_post
		"""
		# NEAREST CP
		nearest_command_post = enemy_command_posts[0]
		for command_post in enemy_command_posts:
			var nearest_distance =  nearest_command_post.global_transform.origin.distance_to(translation)
			if command_post.global_transform.origin.distance_to(translation) <= nearest_distance:
				nearest_command_post = command_post
		"""
		
		# RANDOM CP
		nearest_command_post = enemy_command_posts[randi()%enemy_command_posts.size()]
		
		var begin : Vector3 = owner.get_node("PathMaker").navigation_node.get_closest_point(owner.get_translation())
		var end := Vector3(rand_range(nearest_command_post.translation.x - 7, nearest_command_post.translation.x + 7), 0, rand_range(nearest_command_post.translation.z - 5, nearest_command_post.translation.z + 5))
		owner.get_node("PathMaker").update_path(begin, end)
		
	# Si no hi han CP enemics
	else:
		idle = true
		var begin : Vector3 = owner.get_node("PathMaker").navigation_node.get_closest_point(owner.get_translation())
		var end := Vector3(rand_range(-200, 200), 0, rand_range(-200, 200))
		owner.get_node("PathMaker").update_path(begin, end)


func _on_ConquestTimer_timeout():
	# conquering_a_cp = false
	emit_signal("finished", "choose_objective")