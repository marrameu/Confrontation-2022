extends Spatial

onready var input : Node = $Input # class per a linput i el physics
onready var physics : Node = $Physics
onready var shooting : Node = $Shooting

var blue_team := false
var is_player_or_ai : int = 0
var pilot_man : PilotManager

var active := false # temporal
var dead := false

var cam : Camera

func _ready():
	pass#init(get_tree().current_scene.get_node("PilotManagers/PlayerMan"))


func init(new_pilot_man : PilotManager) -> bool:
	if is_player_or_ai == 1:
		return false
	elif is_player_or_ai == 2:
		exit()
	
	pilot_man = new_pilot_man
	blue_team = pilot_man.blue_team
	# set_team_color()
	is_player_or_ai = 1 if pilot_man.is_player else 2
	if is_player_or_ai == 1:
		$PlayerHUD.visible = true
		active = true
		cam = get_tree().current_scene.get_node("PlayerVehicleCam")
		#$Listener.make_current() # temporal, a vera com va
		# input.set_script(preload("res://PlayerInput.gd"))
		shooting.set_script(preload("res://src/Vehicles/PlayerGroundVehicleShooting.gd"))
	elif is_player_or_ai == 2:
		pass
		#input.set_script(preload("res://ShipAIInput.gd"))
		#input.set_physics_process(true) # WTF pq cal?
		#shooting.set_script(preload("res://AIShipShooting.gd"))
		#$StateMachine.set_active(true)
	# connect("ship_died", get_tree().current_scene, "_on_ship_died", [pilot_man])
	return true


func _physics_process(delta):
	if not active:
		return
	if Input.is_action_just_pressed("interact"):
		$ExitTimer.start()
	elif Input.is_action_just_released("interact"):
		$ExitTimer.stop()
	var y_change = clamp(input.pitch * delta * 5, -0.5, 0.5)
	var x_change = clamp(input.yaw * delta * 5, -0.5, 0.5)
	if sign(input.pitch) == 1:
		input.pitch = max(input.pitch - delta *50, 0) # exponencial?. Lerp? ço és restar pitch i yaw * delta
	else:
		input.pitch = min(input.pitch + delta *50, 0)
	if sign(input.yaw) == 1:
		input.yaw = max(input.yaw - delta *50, 0) # exponencial?. Lerp? ço és restar pitch i yaw * delta
	else:
		input.yaw = min(input.yaw + delta *50, 0)
	rotation.y = move_toward(rotation.y, rotation.y - y_change, delta / 2)
	$Pivot.rotation.x = clamp(move_toward($Pivot.rotation.x, $Pivot.rotation.x + x_change, delta / 2), deg2rad(-70), deg2rad(20))
	#if active:
	#	input_to_physics(delta)


func exit():
	if is_player_or_ai == 1:
		$PlayerHUD.visible = false
		cam.ship = null
		get_tree().current_scene.spawn_player(translation) # senyals
	elif is_player_or_ai == 2:
		#$StateMachine.set_active(false)
		get_tree().current_scene.spawn_ai_troop(int(pilot_man.name.trim_prefix("AIManager")), false, false, translation) # senyals
	pilot_man = null
	#input.set_script(preload("res://ShipInput.gd"))
	shooting.set_script(preload("res://src/Vehicles/GroundVehicleShooting.gd"))
	# disconnect("ship_died", get_tree().current_scene, "_on_ship_died")
	is_player_or_ai = 0


func input_to_physics(delta):
	var final_angular_input :=  Vector3(input.pitch, input.yaw, 0.0)
	physics.set_physics_input(final_angular_input, delta)
