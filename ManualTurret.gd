extends Spatial

onready var input : Node = $Input # class per a linput i el physics
onready var physics : Node = $Physics
onready var shooting : Node = $Shooting

var blue_team := false
var is_player_or_ai : int = 0
var pilot_man : PilotManager

var active := false # temporal

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
		#$Listener.make_current() # temporal, a vera com va
		#input.set_script(preload("res://PlayerInput.gd"))
		#shooting.set_script(preload("res://PlayerShipShooting.gd"))
	elif is_player_or_ai == 2:
		pass
		#input.set_script(preload("res://ShipAIInput.gd"))
		#input.set_physics_process(true) # WTF pq cal?
		#shooting.set_script(preload("res://AIShipShooting.gd"))
		#$StateMachine.set_active(true)
	# connect("ship_died", get_tree().current_scene, "_on_ship_died", [pilot_man])
	return true


func _physics_process(delta):
	var y_change = clamp(input.pitch / 2, -250, 250) * delta
	var x_change = clamp(input.yaw / 2, -250, 250) * delta
	input.pitch -= y_change * 4 # exponencial?
	input.yaw -= x_change * 4
	rotation.y = move_toward(rotation.y, rotation.y + y_change, delta / 5)
	$Pivot.rotation.x = move_toward($Pivot.rotation.x, $Pivot.rotation.x + x_change, delta / 5)
	#if active:
	#	input_to_physics(delta)


func exit():
	pass


func input_to_physics(delta):
	var final_angular_input :=  Vector3(input.pitch, input.yaw, 0.0)
	physics.set_physics_input(final_angular_input, delta)
