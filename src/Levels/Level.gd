extends Spatial

signal battle_started
signal ship_added
signal big_ship_shields_down
signal match_msg

var player_scene : PackedScene = preload("res://src/Troops/Player.tscn")
var ai_troop_scene : PackedScene = preload("res://src/Troops/AI/Troop.tscn")

var blue_points = 0
var red_points = 0
var MAX_POINTS = 1000

var battle_started := false

var num_of_players : int = 16

# middle point
var middle_point := 0.0
var blue_point := 0.0
var num_of_blues : int = 0
var red_point := 0.0
var num_of_reds : int = 0

var RED_LIMIT = -3000
var BLUE_LIMIT = 3000

var blue_take_over := false
var red_take_over := false
# Called when the node enters the scene tree for the first time.
func _ready():
	for big_ship in $BigShips.get_children():
		emit_signal("ship_added", big_ship)
		big_ship.connect("shields_down", self, "_on_BigShip_shields_down")
		big_ship.connect("destroyed", self, "_on_BigShip_destroyed")
	
	for cp in $"%CommandPosts".get_children():
		cp.connect("add_points", self, "_on_cp_add_points")
	
	$PilotManagers/PlayerMan.blue_team = PlayerInfo.player_blue_team
	
	$WaitingCam.make_current()
	$SpawnHUD.show()


func _process(delta):
	$MatchUI.middle_point_value = middle_point * 1/30 # 
	$MatchUI/Label.text = "PUNTS VERMELLS: " + str(red_points) + "\nPUNTS BLAUS: " + str(blue_points)


func _physics_process(delta):
	update_middle_point(delta)


func update_middle_point(delta): 
	blue_point = 0.0
	red_point = 0.0
	
	for ship in get_tree().get_nodes_in_group("Ships"):
		if ship.pilot_man and ship.translation.y > 700:
			if not ship.pilot_man.blue_team:
				red_point += (ship.translation.x - RED_LIMIT + 2000) # la distància des de la seva nau capital
			else:
				blue_point += (ship.translation.x - BLUE_LIMIT - 2000) # el 2000 és la penalització dels morts, potser és massa alta
		
	red_point /= 5#num_of_players + num_of_temp_ai
	blue_point /= 5#num_of_players + num_of_temp_ai
	
	for attack_ship in get_tree().get_nodes_in_group("AttackShips"):
		if attack_ship.blue_team:
			pass
			blue_point -= 650
		else:
			pass
			red_point += 650
	
	var des_middle_point = (red_point + blue_point) / 2
	middle_point = lerp(middle_point, des_middle_point, 0.3 * delta)
	#$RedPoint.translation.x = red_point
	#$BluePoint.translation.x = blue_point
	#$MiddlePoint.translation.x = clamp(middle_point, RED_LIMIT, BLUE_LIMIT)
	#$Label.text = "MIDDLE_POINT = " + str(int(middle_point), "    ", str(int(des_middle_point)))
	
	if middle_point > 1250 and not red_take_over:
		red_take_over = true
		emit_signal("match_msg", "ELS BLAUS SÓN REPRIMITS", false)
	elif middle_point < -1250 and not blue_take_over:
		blue_take_over = true
		emit_signal("match_msg", "ELS VERMELLS SÓN REPRIMITS", true)
	elif middle_point < 1250 and middle_point > -1250:
		blue_take_over = false
		red_take_over = false


func _on_player_entered_ship(ship : Spatial):
	$PlayerShipCam.ship = ship
	ship.cam = $PlayerShipCam # no hauria de caldre
	$PlayerShipCam.make_current()
	$PlayerShipCam.init_cam()
	


func spawn_player(pos := Vector3(0, 2, 0)) -> Spatial:
	var new_player = player_scene.instance()
	new_player.translation = pos
	new_player.pilot_man = $PilotManagers/PlayerMan
	add_child(new_player)
	$PlayerTroopCam.cam_pos_path = new_player.get_node("CameraBase/CameraPosition").get_path()
	new_player.connect("entered_ship", self, "_on_player_entered_ship") #cam en lloc de self
	new_player.connect("died", self, "_on_player_died")
	$PlayerTroopCam.make_current()
	return new_player


func spawn_ai_troop(ai_num : int, blue_team := false) -> Spatial:
	var new_troop_man : PilotManager = get_node_or_null("PilotManagers/AIManager" + str(ai_num))
	# crea'n un de nou
	if not new_troop_man:
		new_troop_man = PilotManager.new()
		new_troop_man.name = ("AIManager" + str(ai_num))
		new_troop_man.blue_team = blue_team
		$PilotManagers.add_child(new_troop_man)
	
	
	var new_troop = ai_troop_scene.instance()
	
	var own_cps : Array
	for cp in get_tree().get_nodes_in_group("CommandPosts"):
		if cp.m_team == 1 and not new_troop_man.blue_team:
			own_cps.append(cp)
		elif cp.m_team == 2 and new_troop_man.blue_team:
			own_cps.append(cp)
	if own_cps:
		var my_cp : CommandPost = own_cps[randi() % own_cps.size()]
		new_troop.translation = my_cp.global_transform.origin + Vector3(rand_range(-15, 15), 2, rand_range(-15, 15))
	else:
		pass
	
	new_troop.pilot_man = new_troop_man
	new_troop.connect("died", self, "_on_ai_troop_died", [ai_num])
	add_child(new_troop)
	
	return new_troop


func start_battle():
	if battle_started:
		return
	
	var blue_ais : int = num_of_players
	var red_ais : int = num_of_players
	var ai_num : int = 0
	
	if PlayerInfo.player_blue_team:
		blue_ais -= 1
	else:
		red_ais -= 1
	
	var x : int = 0
	while x < blue_ais:
		x += 1
		spawn_ai_troop(ai_num, true)
		ai_num += 1
	
	var y : int = 0
	while y < red_ais:
		y += 1
		spawn_ai_troop(ai_num, false)
		ai_num += 1
	
	battle_started = true
	emit_signal("battle_started")


func _on_player_died():
	$WaitingCam.make_current()
	$SpawnHUD.show()


func _on_ship_died(pilot_man : PilotManager) -> void:
	if pilot_man: # no caldria, però per si un cas
		if pilot_man.blue_team:
			red_point += 5
		else:
			blue_points += 5
		if pilot_man.is_player:
			_on_player_died()


func _on_ai_troop_died(ai_num : int):
	var t = Timer.new()
	t.set_wait_time(5) # 20 o més
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.connect("timeout", self, "spawn_ai_troop", [ai_num])
	t.connect("timeout", t, "queue_free")
	
	var is_blue : bool = get_node_or_null("PilotManagers/AIManager" + str(ai_num)).blue_team
	if is_blue:
		red_points += 1 # potser una mica més
	else:
		blue_points += 1
	# emit_signal("match_msg", "SHIP " + str(num) + " HA ESTAT ELIMINADA", !is_blue)


func _on_SpawnHUD_change_cam():
	$WaitingCam.translation = Vector3(0, 5000, 0)
	$WaitingCam.rotation_degrees = Vector3(-90, 0, 0)


func _on_BigShip_shields_down(ship):
	emit_signal("big_ship_shields_down", ship)
	var msg_blue : bool = !ship.blue_team
	emit_signal("match_msg", ship.name + " HA PERDUT ELS ESCUTS", msg_blue)


func _on_BigShip_destroyed(ship : Spatial):
	emit_signal("match_msg", ship.name + " HA ESTAT DESTRUÏDA", !ship.blue_team)
	if ship.is_in_group("CapitalShips"):
		if not ship.blue_team:
			red_points += 200
		else:
			blue_points += 200
	elif ship.is_in_group("SupportShips"):
		if not ship.blue_team:
			red_points += 100
		else:
			blue_points += 100
	elif ship.is_in_group("AttackShips"):
		if not ship.blue_team:
			red_points += 30
		else:
			blue_points += 30


func _on_cp_add_points(blue_team : bool) -> void:
	if blue_team:
		blue_points += 10
	else:
		red_points += 10
