extends Spatial

signal battle_started
signal ship_added

var player_scene : PackedScene = preload("res://src/Troops/Player.tscn")
var ai_troop_scene : PackedScene = preload("res://src/Troops/AI/Troop.tscn")

var middle_point = 0.0

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
	"""cam en lloc de self"""
	new_player.connect("entered_ship", self, "_on_player_entered_ship")
	$PlayerTroopCam.make_current()
	return new_player


func spawn_ai_troop(ai_num : int, blue_team := false, pos := Vector3(0, 2, 0)) -> Spatial:
	var new_troop_man : PilotManager = get_node_or_null("PilotManagers/AIManager" + str(ai_num))
	# crea'n un de nou
	if not new_troop_man:
		new_troop_man = PilotManager.new()
		new_troop_man.name = ("AIManager" + str(ai_num))
		new_troop_man.blue_team = blue_team
		$PilotManagers.add_child(new_troop_man)
	
	
	var new_troop = ai_troop_scene.instance()
	new_troop.translation = Vector3(rand_range(-250, 250), 2, rand_range(-250, 250))
	new_troop.pilot_man = new_troop_man
	new_troop.connect("died", self, "_on_ai_troop_died", [ai_num])
	add_child(new_troop)
	
	return new_troop


func start_battle():
	if battle_started:
		return
	
	spawn_player()
	
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


func _on_ai_troop_died(ai_num : int):
	var t = Timer.new()
	t.set_wait_time(5) # 20 o més
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.connect("timeout", self, "spawn_ai_troop", [ai_num])
	t.connect("timeout", t, "queue_free")
	
	# var msg_blue : bool = !get_node_or_null("PilotManagers/AIManager" + str(num)).blue_team
	# emit_signal("match_msg", "SHIP " + str(num) + " HA ESTAT ELIMINADA", msg_blue)
