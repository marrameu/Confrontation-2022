extends Node3D

signal battle_started
signal battle_finished
signal ship_added
signal big_ship_shields_down
signal match_msg

var player_scenes := { 0 : preload("res://src/Troops/Player/NewPlayerRifle.tscn"), 1 : preload("res://src/Troops/Player/NewPlayerMissileLauncher.tscn")}
var ai_troop_scene : PackedScene = preload("res://src/Troops/AI/AITroop.tscn")

var blue_points = 0
var red_points = 0
var MAX_POINTS = 500

var has_battle_started := false

var num_of_players : int = 20
var num_of_space_troops : int = 8

# middle point
var middle_point := 0.0
var blue_point := 0.0
var num_of_blues : int = 0
var red_point := 0.0
var num_of_reds : int = 0

var RED_LIMIT = -3000
var BLUE_LIMIT = 3000

# msgs
var blue_take_over := false
var red_take_over := false
var red_deads_count : int = 0
var blue_deads_count : int = 0


func _ready():
	for big_ship in $BigShips.get_children():
		emit_signal("ship_added", big_ship)
		big_ship.connect("shields_down",Callable(self,"_on_BigShip_shields_down"))
		big_ship.connect("destroyed",Callable(self,"_on_BigShip_destroyed"))
	
	if get_node_or_null("%CommandPosts"): # debug espai
		for cp in $"%CommandPosts".get_children():
			cp.connect("add_points",Callable(self,"_on_cp_add_points"))
			cp.team_changed.connect(_on_cp_team_changed)

	$PilotManagers/PlayerMan.blue_team = PlayerInfo.player_blue_team
	
	$WaitingCam.make_current()
	$SpawnHUD.show()


func _process(delta):
	$MatchUI.middle_point_value = middle_point * 1/30 # 
	$MatchUI/Label.text = "PUNTS VERMELLS: " + str(red_points) + "\nPUNTS BLAUS: " + str(blue_points)


func _physics_process(delta):
	update_middle_point(delta)
	if red_points >= MAX_POINTS or blue_points >= MAX_POINTS:
		emit_signal("battle_finished")
		get_tree().paused = true
	if red_deads_count >= 100:
		emit_signal("match_msg", "RED TEAM IS LOSING UNITS", true)
		red_deads_count = 0
	elif blue_deads_count >= 100:
		emit_signal("match_msg", "BLUE TEAM IS LOSING UNITS", false)
		blue_deads_count = 0


func update_middle_point(delta): 
	blue_point = 0.0
	red_point = 0.0
	
	var total_num_of_ships : int = 0
	
	for ship in get_tree().get_nodes_in_group("Ships"):
		if ship.pilot_man and ship.position.y > 700:
			total_num_of_ships += 1
			if not ship.blue_team:
				red_point += (ship.position.x - RED_LIMIT + 2000) # la distància des de la seva nau capital
			else:
				blue_point += (ship.position.x - BLUE_LIMIT - 2000) # el 2000 és la penalització dels morts, potser és massa alta
	
	if total_num_of_ships != 0:
		red_point /= total_num_of_ships
		blue_point /= total_num_of_ships
	
	for attack_ship in get_tree().get_nodes_in_group("AttackShips"):
		if attack_ship.blue_team:
			pass
			blue_point -= 650
		else:
			pass
			red_point += 650
	
	var des_middle_point = (red_point + blue_point) / 2
	middle_point = lerp(middle_point, des_middle_point, 0.3 * delta)
	$RedPoint.position.x = red_point
	$BluePoint.position.x = blue_point
	$MiddlePoint.position.x = clamp(middle_point, RED_LIMIT, BLUE_LIMIT)
	#$Label.text = "MIDDLE_POINT = " + str(int(middle_point), "    ", str(int(des_middle_point)))
	
	if middle_point > 1250 and not red_take_over:
		red_take_over = true
		emit_signal("match_msg", "BIG SHIPS ARE BEING ATTACKED", false)
	elif middle_point < -1250 and not blue_take_over:
		blue_take_over = true
		emit_signal("match_msg", "BIG SHIPS ARE BEING ATTACKED", true)
	elif middle_point < 1250 and middle_point > -1250:
		blue_take_over = false
		red_take_over = false


func spawn_player(pos := Vector3(0, 2, 0)) -> Node3D:
	var new_player = player_scenes[$SpawnHUD.selected_class_ind].instantiate()
	new_player.position = pos
	new_player.pilot_man = $PilotManagers/PlayerMan
	add_child(new_player)
	$CameraBase.player_path = new_player.get_path()
	$PauseMenu.respawn.connect(new_player._on_respawn)
	
	new_player.connect("entered_ship",Callable($PlayerShipCam,"_on_player_entered_ship"))
	new_player.connect("entered_vehicle",Callable($PlayerVehicleCam,"_on_player_entered_vehicle"))
	
	new_player.entered_ship.connect(_on_player_entered_vehicle) # fer-ho amb Autoload Signals.gd?
	new_player.entered_vehicle.connect(_on_player_entered_vehicle)
	
	new_player.connect("died",Callable(self,"_on_player_died"))
	$CameraBase.get_node("%PlayerTroopCam").make_current()
	return new_player


func spawn_ai_troop(ai_num : int, blue_team := false, spawn_in_space := false, pos := Vector3.ZERO) -> Node3D:
	var new_troop_man : AIPilotManager = get_node_or_null("PilotManagers/AIManager" + str(ai_num))
	# crea'n un de nou
	if not new_troop_man:
		new_troop_man = AIPilotManager.new()
		new_troop_man.name = ("AIManager" + str(ai_num))
		new_troop_man.nickname = ("Troop " + str(ai_num)) # array de noms que es va esborrant i sempre agafa el primer
		new_troop_man.blue_team = blue_team
		new_troop_man.spawn_in_space = spawn_in_space
		
		$PilotManagers.add_child(new_troop_man)
	
	var my_cp : CommandPost
	var own_cps : Array
	for cp in get_tree().get_nodes_in_group("CommandPosts"):
		if not new_troop_man.spawn_in_space:
			if cp.is_in_group("SpaceCP"):
				continue
		elif not cp.is_in_group("SpaceCP"):
			continue
		
		if cp.m_team == 1 and not new_troop_man.blue_team:
			own_cps.append(cp)
		elif cp.m_team == 2 and new_troop_man.blue_team:
			own_cps.append(cp)
	if own_cps:
		my_cp = own_cps[randi() % own_cps.size()]
	else:
		get_tree().create_timer(5).connect("timeout",Callable(self,"spawn_ai_troop").bind(ai_num))
		return null
	
	var new_troop = ai_troop_scene.instantiate()
	
	new_troop.pilot_man = new_troop_man
	# ES POT FER MILLOR, COM AMB EL PLAYER
	if pos == Vector3.ZERO:
		new_troop.position = my_cp.global_transform.origin + Vector3(randf_range(-15, 15), 2, randf_range(-15, 15))
	else:
		new_troop.position = pos
	new_troop.connect("died",Callable(self,"_on_ai_troop_died").bind(ai_num))
	add_child(new_troop)
	
	return new_troop


func start_battle():
	if has_battle_started:
		return
	
	var blue_ais : int = num_of_players
	var red_ais : int = num_of_players
	var ai_num : int = 0
	
	if PlayerInfo.player_blue_team:
		blue_ais -= 1
	else:
		red_ais -= 1
	
	var x : int = 0
	var x_spawn_in_space : int = 0
	while x < blue_ais:
		x += 1
		var spawn_in_space := false
		if x_spawn_in_space < num_of_space_troops:
			spawn_in_space = true
			x_spawn_in_space += 1
		spawn_ai_troop(ai_num, true, spawn_in_space)
		ai_num += 1
	
	var y : int = 0
	var y_spawn_in_space : int = 0
	while y < red_ais:
		y += 1
		var spawn_in_space := false
		if y_spawn_in_space < num_of_space_troops:
			spawn_in_space = true
			y_spawn_in_space += 1
		spawn_ai_troop(ai_num, false, spawn_in_space)
		ai_num += 1
	
	for attack_ship in get_tree().get_nodes_in_group("AttackShips"):
		attack_ship.can_move = true
	
	has_battle_started = true
	emit_signal("battle_started")


func _on_player_died():
	$WaitingCam.make_current()
	$SpawnHUD.enable_spawn(false)
	$SpawnHUD.show()
	if PlayerInfo.player_blue_team:
		red_point += 10
		blue_deads_count += 10
	else:
		blue_point += 10
		red_deads_count += 10


func _on_ship_died(pilot_man : PilotManager) -> void:
	if pilot_man: # no caldria, però per si un cas
		if pilot_man.blue_team:
			red_point += 5
			blue_deads_count += 5
		else:
			blue_points += 5
			red_deads_count += 10
		if pilot_man.is_player:
			_on_player_died()
		else:
			_on_ai_troop_died(str(pilot_man.name).trim_prefix("AIManager").to_int())


func _on_ai_troop_died(ai_num : int):
	var t = Timer.new()
	t.set_wait_time(20)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.connect("timeout",Callable(self,"spawn_ai_troop").bind(ai_num))
	t.connect("timeout",Callable(t,"queue_free"))
	
	var is_blue : bool = get_node_or_null("PilotManagers/AIManager" + str(ai_num)).blue_team
	if is_blue:
		red_points += 1 # potser una mica més
		blue_deads_count += 1
	else:
		blue_points += 1
		red_deads_count += 1


func _on_BigShip_shields_down(ship):
	for normal_ship in get_tree().get_nodes_in_group("Ships"):
		normal_ship.on_BigShip_shields_down(ship)
	#emit_signal("big_ship_shields_down", ship) # NO SÉ COM CONNECTAR-HO GUAI :/ -> QUAN LA BIGSHIP FA READY HO CONNECTA AMB TOTES LES NAUS? PERÒ I SI FAN SPAWN MÉS NAUS?
	var msg_blue : bool = !ship.blue_team
	emit_signal("match_msg", ship.name, " HA PERDUT ELS ESCUTS", msg_blue)


func _on_BigShip_destroyed(ship : Node3D):
	emit_signal("match_msg", ship.name, " HA ESTAT DESTRUÏDA", !ship.blue_team)
	if ship.is_in_group("CapitalShips"):
		if ship.blue_team:
			red_points += 200
		else:
			blue_points += 200
	elif ship.is_in_group("SupportShips"):
		if ship.blue_team:
			red_points += 100
		else:
			blue_points += 100
	elif ship.is_in_group("AttackShips"):
		if ship.blue_team:
			red_points += 50
		else:
			blue_points += 50


func _on_cp_add_points(blue_team : bool) -> void:
	if blue_team:
		blue_points += 10
	else:
		red_points += 10


func _on_cp_added():
	$SpawnHUD.get_node("%CPButtons").update()


func _on_player_entered_vehicle(vehicle):
	$PauseMenu.respawn.connect(vehicle._on_respawn)


func _on_cp_team_changed(old_team : int, new_team : int):
	var blue_team : bool
	if new_team == 0:
		blue_team = true if old_team == 1 else false
		emit_signal("match_msg", "A CP WAS TAKEN DOWN", blue_team)
	else:
		blue_team = true if new_team == 2 else false
		emit_signal("match_msg", "A CP WAS CAPTURED", blue_team)
