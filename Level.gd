extends Spatial

signal battle_started
signal ship_added
signal big_ship_shields_down
signal match_msg

const player_ship_scene : PackedScene = preload("res://PlayerShip.tscn")
const ai_ship_scene : PackedScene = preload("res://AIShip.tscn")

var battle_started := false
var battle_time := 0.0

var num_of_players := 5
var num_of_temp_ai := 0

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
	
	$PilotManagers/PlayerManager.blue_team = PlayerInfo.player_blue_team
	
	$WaitingCam.make_current()


func _process(delta):
	$MatchUI.middle_point_value = middle_point * 1/30 # o menys, 1500-2000 potser
	if battle_started:
		battle_time += delta
	if Input.is_action_just_pressed("test"):
		spawn_AI(100 + num_of_temp_ai, randi() % 2)
		num_of_temp_ai += 1


func _physics_process(delta):
	update_middle_point(delta)


func update_middle_point(delta): 
	blue_point = 0.0
	red_point = 0.0
	
	for ship in $Ships.get_children():
		if not ship.pilot_man.blue_team:
			red_point += (ship.translation.x - RED_LIMIT + 2000) # la distància des de la seva nau capital
		else:
			blue_point += (ship.translation.x - BLUE_LIMIT - 2000) # el 2000 és la penalització dels morts, potser és massa alta
	
	red_point /= num_of_players + num_of_temp_ai
	blue_point /= num_of_players + num_of_temp_ai
	
	for attack_ship in get_tree().get_nodes_in_group("AttackShips"):
		if attack_ship.blue_team:
			pass
			blue_point -= 650
		else:
			pass
			red_point += 650
	
	var des_middle_point = (red_point + blue_point) / 2
	middle_point = lerp(middle_point, des_middle_point, 0.3 * delta)
	$RedPoint.translation.x = red_point
	$BluePoint.translation.x = blue_point
	$MiddlePoint.translation.x = clamp(middle_point, RED_LIMIT, BLUE_LIMIT)
	$Label.text = "MIDDLE_POINT = " + str(int(middle_point), "    ", str(int(des_middle_point)))
	
	if middle_point > 1250 and not red_take_over:
		red_take_over = true
		emit_signal("match_msg", "ELS BLAUS SÓN REPRIMITS", false)
	elif middle_point < -1250 and not blue_take_over:
		blue_take_over = true
		emit_signal("match_msg", "ELS VERMELLS SÓN REPRIMITS", true)
	elif middle_point < 1250 and middle_point > -1250:
		blue_take_over = false
		red_take_over = false


func _on_BigShip_destroyed(ship : Spatial):
	emit_signal("match_msg", ship.name + " HA ESTAT DESTRUÏDA", !ship.blue_team)
	if ship.is_in_group("CapitalShips"):
		$Results/Control.show()
		if not ship.blue_team:
			$Results/Control/RichTextLabel.show()
		else:
			$Results/Control/RichTextLabel2.show()
	# stop tot


func _on_PlayerShip_tree_exited():
	$WaitingCam.make_current()
	$SpawnHUD.enable_spawn(false)
	$SpawnHUD.show()
	
	var msg_blue : bool = !PlayerInfo.player_blue_team # potser ferho amb el pilotman
	emit_signal("match_msg", "PLAYERSHIP HA ESTAT ELIMINADA", msg_blue)


func _on_AIShip_tree_exited(num):
	var t = Timer.new()
	t.set_wait_time(20)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.connect("timeout", self, "spawn_AI", [num])
	t.connect("timeout", t, "queue_free")
	
	var msg_blue : bool = !get_node_or_null("PilotManagers/AIManager" + str(num)).blue_team
	emit_signal("match_msg", "SHIP " + str(num) + " HA ESTAT ELIMINADA", msg_blue)


func spawn_player():
	var ship = player_ship_scene.instance()
	ship.pilot_man = $PilotManagers/PlayerManager
	ship.translation = choose_spawn_position(ship.pilot_man.blue_team)
	ship.rotation_degrees.y = -90 if ship.pilot_man.blue_team else 90
	$Ships.add_child(ship)
	
	ship.connect("tree_exited", self, "_on_PlayerShip_tree_exited")
	
	$SpawnHUD/Control.hide()
	
	# cam
	#ship.get_node("Input").connect("activated_turboing", $Camera, "_on_Input_activated_turboing")
	$Camera.ship = ship
	ship.cam = $Camera
	$Camera.make_current()
	$Camera.init_cam()
	
	emit_signal("ship_added", ship)


func spawn_AI(number, blue_team : bool = false):
	var ship = ai_ship_scene.instance()
	
	var pilot_man : PilotManager = get_node_or_null("PilotManagers/AIManager" + str(number))
	# crea'n un de nou
	if not pilot_man:
		pilot_man = PilotManager.new()
		$PilotManagers.add_child(pilot_man)
		pilot_man.name = ("AIManager" + str(number))
		pilot_man.blue_team = blue_team
	
	ship.pilot_man = pilot_man
	ship.battle_man = self
	connect("big_ship_shields_down", ship, "_on_BigShip_shields_down")
	
	ship.translation = choose_spawn_position(pilot_man.blue_team)
	ship.rotation_degrees.y = -90 if pilot_man.blue_team else 90
	$Ships.add_child(ship)
	
	ship.connect("ship_died", self, "_on_AIShip_tree_exited", [number])
	
	var b = true if pilot_man.blue_team else false
	var r = false if pilot_man.blue_team else true
	#$BigShips/CapitalShipBlue/HealthSystem.connect("shield_die", ship.get_node("StateMachine"), "capital_ship_shield_died", [b])
	#$BigShips/CapitalShipRed/HealthSystem.connect("shield_die", ship.get_node("StateMachine"), "capital_ship_shield_died", [r])
	
	emit_signal("ship_added", ship)


# això?! endaya. q dius?
func choose_spawn_position(blue_team : bool) -> Vector3:
	if blue_team:
		return(Vector3(rand_range(BLUE_LIMIT - 50, BLUE_LIMIT + 50), rand_range(-250, -350), rand_range(-500, 500)))
	else:
		return(Vector3(rand_range(RED_LIMIT - 50, RED_LIMIT + 50), rand_range(-250, -350), rand_range(-500, 500)))
	
	"""
		# POTSER cal fer algun clamp
	if blue_team:
		var blue_spawn = (BLUE_LIMIT + middle_point) / 2
		return(Vector3(rand_range(blue_spawn - 50, blue_spawn + 50), rand_range(-50, 50), rand_range(-500, 500)))
	else:
		var red_spawn = (RED_LIMIT + middle_point) / 2
		return(Vector3(rand_range(red_spawn - 50, red_spawn + 50), rand_range(-50, 50), rand_range(-500, 500)))
	"""


func start_battle():
	if battle_started:
		return
	
	battle_started = true
	emit_signal("battle_started")
	
	var blue_ais : int = num_of_players
	var red_ais : int = num_of_players
	var ai_num : int = 0
	
	if PlayerInfo.player_blue_team:
		blue_ais -=1
	else:
		red_ais -= 1
	
	var x : int = 0
	while x < blue_ais:
		x += 1 
		spawn_AI(ai_num, true)
		ai_num += 1
	
	var y : int = 0
	while y < red_ais:
		y += 1
		spawn_AI(ai_num, false)
		ai_num += 1


func _on_BigShip_shields_down(ship):
	emit_signal("big_ship_shields_down", ship)
	var msg_blue : bool = !ship.blue_team
	emit_signal("match_msg", ship.name + " HA PERDUT ELS ESCUTS", msg_blue)
