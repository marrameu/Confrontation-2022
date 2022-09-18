extends "res://src/HealthSystem/HealthSystem.gd"


func _on_HealthSystem_die() -> void:
	if get_tree().has_multiplayer_peer():
		if is_multiplayer_authority():
			get_node("../RespawnTimer").start()
	else:
		get_node("../RespawnTimer").start()
	
	if get_tree().has_multiplayer_peer():
		rpc("die")
	else:
		die()


func _on_RespawnTimer_timeout() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var selection_menu : SelectionMenu = get_node("/root/Main").selection_menus[get_parent().number_of_player - 1]
	var spawn_menu = selection_menu.get_node("Container/SpawnMenu")
	spawn_menu.get_node("SpawnButton").hide()
	spawn_menu.show()
	
	#2/8/21 -> ARREGLAT?
	var i = false
	for cp in get_tree().get_nodes_in_group("CommandPosts"):
		if not i:
			cp.buttons[get_parent().number_of_player - 1].grab_focus()
			i = true


@rpc(any_peer, call_local) func die() -> void:
	health = 0 # Per al HUD (temporal)
	get_node("../TroopManager").is_alive = false
	
	if get_tree().has_multiplayer_peer(): # Per al mode un jugador
		if is_multiplayer_authority():
			get_parent().update_network_info()
	
	update_components(false)
	
	var scene_camera : Camera3D = get_node("/root/Main").players_cameras[get_parent().number_of_player - 1].scene_camera
	if scene_camera:
		if get_tree().has_multiplayer_peer():
			if is_multiplayer_authority():
				scene_camera.make_current()
		else:
			scene_camera.make_current()


@rpc(any_peer, call_local) func respawn() -> void:
	get_node("../TroopManager").is_alive = true
	
	# comprova si hi ha posts dissponibles, sols cal que ho faça el servidor
	var command_posts := []
	for command_post in get_tree().get_nodes_in_group("CommandPosts"):
		if command_post.m_team == get_node("../TroopManager").m_team:
			command_posts.push_back(command_post)
		if command_posts.size() < 1:
			# No hi ha cps del teu equip
			get_parent().global_transform.origin = Vector3(randf_range(-200, 200), 2, randf_range(-200, 200))
		else:
			get_parent().global_transform.origin = get_parent().spawn_position
	
	get_parent().rotation = Vector3()
	
	update_components(true)
	
	var scene_camera : Camera3D = get_node("/root/Main").players_cameras[get_parent().number_of_player - 1].scene_camera
	if scene_camera:
		if get_tree().has_multiplayer_peer():
			if is_multiplayer_authority():
				scene_camera.clear_current()
		else:
			scene_camera.clear_current()
	
	heal(MAX_HEALTH)


@rpc(any_peer, call_local) func update_components(enable : bool, update_interaction := true) -> void:
	# si no és el network master es podria obviar de fer moltes coses
	# perquè no es mogui, oi?
	get_parent().set_process(enable)
	get_parent().set_physics_process(enable)
	
	# pq si no surt disparat?
	get_node("../StateMachine/Movement/Move").velocity = Vector3()
	
	# pq s'aixequi
	if get_node("../Crouch").crouching:
		get_node("../Crouch").get_up()
	# pq es pugui o no ajupir i moure la càm.
	get_node("../Crouch").set_process(enable)
	get_node("../CameraBase").set_process(enable)
	
	if update_interaction:
		get_node("../Interaction").set_process(enable)
	
	get_node("../CollisionShape3D").disabled = !enable
	
	for weapon in get_node("../Weapons").get_children():
		weapon.shooting = false
		weapon.set_process(enable)
		
		var weapon_hud = weapon.get_node("HUD")
		if weapon_hud:
			for child in weapon_hud.get_children():
				if child is Control:
					child.visible = enable
	
	for child in get_parent().get_children():
		# print("uwu")
		if child is Node3D:
			child.visible = enable
	
	if get_tree().has_multiplayer_peer():
		if not is_multiplayer_authority():
			return
	
	if enable:
		get_node("/root/Main/Splitscreen").get_player(get_parent().number_of_player - 1).viewport.get_node("PuppetCam").target = get_node("../CameraBase/Camera3D")
	get_node("../CameraBase/Camera3D").current = enable
	get_node("../AudioListener3D").current = enable
