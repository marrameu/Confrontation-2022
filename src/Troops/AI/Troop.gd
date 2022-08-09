extends StaticBody

class_name Troop

signal died

# Materials
export var body : NodePath

var pilot_man : PilotManager

# Atack
var current_enemy : Spatial

var dead := false

 # terra i aire
var searching_ship := false



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
	
	# Shoot
	if current_enemy and weakref(current_enemy).get_ref():
		if current_enemy.pilot_man:
			if not current_enemy.translation == translation:
				look_at(current_enemy.translation, Vector3(0, 1, 0))
			rotation = Vector3(0, rotation.y + deg2rad(180), 0)
			if not $Weapons/AIGun.shooting:
				$Weapons/AIGun.shooting = true
			return
		else:
			for i in range(0, $EnemyDetection.enemies.size()):
				if not $EnemyDetection.enemies.size() > i:
					return
				if $EnemyDetection.enemies[i] == current_enemy:
					$EnemyDetection.enemies.remove(i)
			current_enemy = null
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
	#going_to_cp_to_conquer = false
	#conquering_a_cp = false
	#idle = false
	#space = false
	searching_ship = false
	#my_cap_ship = null
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
			
			#space = global_transform.origin.y > 1000 # millor fer-ho depenent del CP
			#if space:
			#	cp.get_node("../../").rpc("add_fill", get_path())
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
		
		#space = global_transform.origin.y > 1000 # millor fer-ho depenent del CP
		#if space:
		#	cp.get_node("../../").add_fill(get_path())
	
	set_process(true)
	$PathMaker.set_process(true)
	
	for child in get_children():
		if child.has_method("show"):
			child.show()
	
	$HealthSystem.heal($HealthSystem.MAX_HEALTH)


func set_material() -> void:
	if get_node("TroopManager").m_team == get_node("/root/Main").local_players[0].get_node("TroopManager").m_team:
		get_node(body).set_surface_material(2, load("res://assets/models/mannequiny/Azul_R.material"))
	else:
		get_node(body).set_surface_material(4, load("res://assets/models/mannequiny/Azul_L.material"))



func _on_InitTimer_timeout():
	wait_to_init = false
