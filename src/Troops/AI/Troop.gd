extends StaticBody

class_name Troop

signal died

# Materials
export var body : NodePath

var pilot_man : PilotManager

# Atack
var current_enemie : Spatial

# States (State Machine)
var space := false # canviar-ho depenent del CP
var my_cap_ship : Spatial # cal?

var dead := false

 # terra i aire
var searching_ship := false

# terra
var idle := false
var going_to_cp_to_conquer := false
var conquering_a_cp := false

var nickname := "Troop"

# Networking
puppet var slave_position : = Vector3()
puppet var slave_rotation : = 0.0

# temproal
var wait_a_fcking_moment := false
var wait_to_init := true

export var red_mat : Material
export var blue_mat : Material


func _ready():
	$TeamIndicator.material_override = blue_mat if pilot_man.blue_team else red_mat


# Client
func init() -> void:
	if get_node("TroopManager").is_alive:
		pass
		# if start_in_a_vehicle:
		#	disable_components(false)
	else:
		die()


# TOT AÇÒ NECESSITA UNA STATE MACHINE O, ALEMNYS, MÉS FUNCIONS SEPARADES o MATCH
func _process(delta):
	#$PlayerMesh.moving = !$PathMaker.finished
	if get_tree().has_network_peer():
		if not get_tree().is_network_server():
			return
	
	if wait_to_init:
		return
	
	# Rotate, hauria de mirar al següent punt del camí i no pas al final de tot
	if $PathMaker.navigation_node:
		look_at($PathMaker.navigation_node.to_global($PathMaker.end), Vector3(0, 1, 0))
		rotation = Vector3(0, rotation.y + deg2rad(180), 0)
	
	# Walk
	# Si ha acabat de caminar o de fer qualsevol cosa (fer-ho amb senyals)
	if $PathMaker.finished:
		idle = false # nse q ve a compondre això
		
		if space:
			if not searching_ship:
				search_ship()
		else:
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
	
	# Shoot
	if current_enemie and weakref(current_enemie).get_ref():
		if current_enemie.pilot_man:
			if not current_enemie.translation == translation:
				look_at(current_enemie.translation, Vector3(0, 1, 0))
			rotation = Vector3(0, rotation.y + deg2rad(180), 0)
			if not $Weapons/AIGun.shooting:
				$Weapons/AIGun.shooting = true
			return
		else:
			for i in range(0, $EnemyDetection.enemies.size()):
				if not $EnemyDetection.enemies.size() > i:
					return
				if $EnemyDetection.enemies[i] == current_enemie:
					$EnemyDetection.enemies.remove(i)
			current_enemie = null
	if $Weapons/AIGun.shooting:
		$Weapons/AIGun.shooting = false


func _physics_process(delta : float) -> void:
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			if translation.y > 1000:
				pass
			rset_unreliable("slave_position", global_transform.origin)
			rset_unreliable("slave_rotation", rotation.y)
		else:
			global_transform.origin = slave_position
			rotation = Vector3(0, slave_rotation, 0)


func _on_HealthSystem_die(attacker) -> void:
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			($RespawnTimer as Timer).start()
			rpc("die")
	else:
		emit_signal("died")
		queue_free()
		# ($RespawnTimer as Timer).start()
		# die()


func _on_RespawnTimer_timeout():
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			rpc("respawn")
	else:
		respawn()


sync func die() -> void:
	#nse q es neceesari i q no
	going_to_cp_to_conquer = false
	conquering_a_cp = false
	idle = false
	space = false
	searching_ship = false
	my_cap_ship = null
	$PathMaker.navigation_node = null
	$ConquestTimer.stop()
	
	$TroopManager.is_alive = false
	
	set_process(false)
	$PathMaker.set_process(false)
	
	$PathMaker.clean_path()
	$EnemyDetection.enemies = []
	
	for child in get_children():
		if child.has_method("hide"):
			child.hide()
	
	$CollisionShape.disabled = true
	
	# Weapons
	for weapon in $Weapons.get_children():
		weapon.shooting = false


sync func respawn() -> void:
	# canviar el parent
	$TroopManager.is_alive = true
	$PathMaker.clean_path()
	
	$CollisionShape.disabled = false
	
	var cp: CommandPost
	
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			var command_posts := []
			for command_post in get_tree().get_nodes_in_group("CommandPosts"):
				if command_post.m_team == $TroopManager.m_team:
					command_posts.push_back(command_post)
				if command_posts.size() < 1:
					# _on_HealthSystem_die()
					global_transform.origin = Vector3(rand_range(-100, 100), 1.6515, rand_range(-100, 100))
				else:
					cp = command_posts[randi()%command_posts.size()]
					global_transform.origin = cp.global_transform.origin #1,815
			
			space = global_transform.origin.y > 1000 # millor fer-ho depenent del CP
			if space:
				cp.get_node("../../").rpc("add_fill", get_path())
	else:
		var command_posts := []
		for command_post in get_tree().get_nodes_in_group("CommandPosts"):
			if command_post.m_team == $TroopManager.m_team:
				command_posts.push_back(command_post)
			if command_posts.size() < 1:
				# _on_HealthSystem_die()
				global_transform.origin = Vector3(rand_range(-100, 100), 1.6515, rand_range(-100, 100))
			else:
				cp = command_posts[randi()%command_posts.size()]
				global_transform.origin = cp.global_transform.origin #1,815
		
		space = global_transform.origin.y > 1000 # millor fer-ho depenent del CP
		if space:
			cp.get_node("../../").add_fill(get_path())
	
	set_process(true)
	$PathMaker.set_process(true)
	
	for child in get_children():
		if child.has_method("show"):
			child.show()
	
	$HealthSystem.heal($HealthSystem.MAX_HEALTH)


func _on_ConquestTimer_timeout():
	conquering_a_cp = false
	# senyal? -> que estiga connectat a una funció universal cel pal "what to do now?"


func set_material() -> void:
	if get_node("TroopManager").m_team == get_node("/root/Main").local_players[0].get_node("TroopManager").m_team:
		get_node(body).set_surface_material(2, load("res://assets/models/mannequiny/Azul_R.material"))
	else:
		get_node(body).set_surface_material(4, load("res://assets/models/mannequiny/Azul_L.material"))


func search_cp_and_conquer(): # àlies terra
	$PathMaker.navigation_node = get_node("/root/Level/Map/Navigation")
	
	# Update Path: Command Posts
	# Cercar els CP enemics
	var enemy_command_posts := []
	for command_post in get_tree().get_nodes_in_group("CommandPosts"):
		if command_post.capturable:
			if command_post.m_team == 0 or (command_post.m_team == 1 and not pilot_man.blue_team) or (command_post.m_team == 2 and pilot_man.blue_team):
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
		
		var begin : Vector3 = $PathMaker.navigation_node.get_closest_point(get_translation())
		var end := Vector3(rand_range(nearest_command_post.translation.x - 7, nearest_command_post.translation.x + 7), 0, rand_range(nearest_command_post.translation.z - 5, nearest_command_post.translation.z + 5))
		$PathMaker.update_path(begin, end)
		
	# Si no hi han CP enemics
	else:
		idle = true
		var begin : Vector3 = $PathMaker.navigation_node.get_closest_point(get_translation())
		var end := Vector3(rand_range(-200, 200), 0, rand_range(-200, 200))
		$PathMaker.update_path(begin, end)


func update_cap_ship(): #bé, nse si seria millor update_navigation_node
	my_cap_ship = null
	
	var ships = get_tree().get_nodes_in_group("CapitalShips")
	var new_ship_pos : Vector3 = Vector3.INF
	for ship in ships: # Com indic que ha de ser un Spatial? O un array de Spatials
		if global_transform.origin.distance_to(ship.global_transform.origin) <  global_transform.origin.distance_to(new_ship_pos):
			new_ship_pos = ship.global_transform.origin
			my_cap_ship = ship
	
	if my_cap_ship:
		$PathMaker.navigation_node = my_cap_ship.get_node("Navigation")
	else:
		print("ERROR: No Capital Ships")


func search_ship(): # comprovar que la nau no hi hagi ningú
	update_cap_ship()
	
	searching_ship = true
	
	"""
	L'inici és get_closest_point de la posició local de la tropa respete el node de navegació.
	Tant l'inici com el final han de ser coordenades locals respecte el node de navegació.
	"""
	var wr = weakref($PathMaker.navigation_node)
	if !wr.get_ref():
		die()
		return
	
	var begin : Vector3 = $PathMaker.navigation_node.get_closest_point($PathMaker.navigation_node.to_local(global_transform.origin)) # s'ha de fer amb la pos. global de la tropa pq, si no, malament rai
	# get_Closest_point perquè no es passi
	var end := Vector3.ZERO #$PathMaker.navigation_node.get_closest_point(begin + Vector3(rand_range(-200, 200), 0, rand_range(-200, 200)))
	
	var choosen_ship : Ship = null
	var ships = get_tree().get_nodes_in_group("Ships")
	var new_ship_pos : Vector3 = Vector3.INF
	for ship in ships: # què fer si no hi ha ships?
		if global_transform.origin.distance_to(ship.global_transform.origin) < global_transform.origin.distance_to(new_ship_pos):
			new_ship_pos = ship.global_transform.origin
	end = $PathMaker.navigation_node.get_closest_point($PathMaker.navigation_node.to_local(new_ship_pos))
	
	$PathMaker.update_path(begin, end)

# CREAR UNA FUNCIO PER A ANAR A UN PUNT ALEATORI (EN UNA DISTÀNCIA ESPECÍFICA)


func _on_InitTimer_timeout():
	wait_to_init = false
