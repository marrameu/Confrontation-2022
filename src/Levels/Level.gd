extends Spatial

signal battle_started
signal ship_added
signal big_ship_shields_down
signal match_msg

var player_scene : PackedScene = preload("res://src/Troops/Player.tscn")
var ai_troop_scene : PackedScene = preload("res://src/Troops/AI/Troop.tscn")

var middle_point = 0.0

var blue_points = 0
var red_points = 0
var MAX_POINTS = 1000

var battle_started := false

var num_of_players : int = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	for big_ship in $BigShips.get_children():
		emit_signal("ship_added", big_ship)
		big_ship.connect("shields_down", self, "_on_BigShip_shields_down")
		big_ship.connect("destroyed", self, "_on_BigShip_destroyed")
	
	$PilotManagers/PlayerMan.blue_team = PlayerInfo.player_blue_team
	
	$WaitingCam.make_current()
	$SpawnHUD.show()


func _process(delta):
	$MatchUI.middle_point_value = middle_point * 1/30 # 
	$MatchUI/Label.text = "PUNTS VERMELLS: " + str(red_points) + "\nPUNTS BLAUS: " + str(blue_points)




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
		red_points += 10
	else:
		blue_points += 10
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
