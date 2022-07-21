extends "res://ShipInput.gd"

const THROTTLE_SPEED := 2.5
const ROLL_SPEED := 2.5

var mouse_input := Vector2()
var input_device : int

var move_right_action := "move_right"
var move_left_action := "move_left"
var move_forward_action := "move_forward"
var move_backward_action := "move_backward"

var camera_down_action := "camera_down"
var camera_up_action := "camera_up"
var camera_left_action := "camera_left"
var camera_right_action := "camera_right"

var turbo_action := "turbo"
var drift_action := "drift"
var zoom_action := "zoom"

var zooming := false


func _process(delta : float) -> void:
	roll = clamp(lerp(roll, (Input.get_action_strength(move_right_action) - 
		Input.get_action_strength(move_left_action)), delta * ROLL_SPEED), -1, 1)
	
	wants_turbo = Input.is_action_just_pressed(turbo_action)
	wants_drift = Input.is_action_just_pressed(drift_action)
	
	zooming = Input.is_action_pressed(zoom_action) and not turboing and not drifting # ferho a la cam tmb
	
	update_yaw_and_ptich()
	var input_strenght := Input.get_action_strength(move_forward_action) - Input.get_action_strength(move_backward_action)
	var des_throttle := 0.5 * input_strenght + 0.5
	update_throttle(des_throttle, delta)


func update_yaw_and_ptich() -> void:
	mouse_input.x = get_node("../PlayerHUD").cursor_input.x
	mouse_input.y = -get_node("../PlayerHUD").cursor_input.y
	
	pitch = mouse_input.y if not Settings.controller_input else Input.get_action_strength(camera_down_action) - Input.get_action_strength(camera_up_action)
	yaw = -mouse_input.x if not Settings.controller_input else Input.get_action_strength(camera_left_action) - Input.get_action_strength(camera_right_action)
	
	if zooming: # fer que quan faci zoom la velocitat de girar és sempre la minima encara q sigui al mig?
		pitch /= 2
		yaw /= 2


func _on_DrainTurboTimer_timeout():
	$TurboSwitchAudio.play()
	avaliable_turbos = clamp(avaliable_turbos - 1, 0, MAX_AVALIABLE_TURBOS)
	wants_turbo = Input.is_action_pressed(turbo_action)
	do_turbo = wants_turbo and avaliable_turbos


"""
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_player_input()


func set_player_input() -> void:
	pass
	
	var ship_camera : Camera = get_node("/root/Main").players_cameras[get_parent().number_of_player - 1].ship_camera
	var player = get_node("/root/Main").local_players[get_parent().number_of_player - 1]
	if not player: # Mirar si es pot treure aquesta comporvació
		return
	input_manager = player.get_node("InputManager")
	input_map = input_manager.input_map
	
	$Player.input_device = input_manager.number_of_device
	
	$Player.move_right_action = input_map.move_right
	$Player.move_left_action = input_map.move_left
	$Player.move_forward_action = input_map.move_forward
	$Player.move_backward_action = input_map.move_backward
	
	$Player.camera_right_action = input_map.camera_right
	$Player.camera_left_action = input_map.camera_left
	$Player.camera_up_action = input_map.camera_up
	$Player.camera_down_action = input_map.camera_down
	
	get_parent().jump_action = input_map.jump
	get_node("../Shooting").shoot_action = input_map.shoot
	get_node("../Shooting").zoom_action = input_map.zoom
	
	ship_camera.input_device = input_manager.number_of_device
	
	ship_camera.zoom_ship_action = input_map.zoom_ship
	ship_camera.look_behind_action = input_map.look_behind
	ship_camera.camera_right_action = input_map.camera_right
	ship_camera.camera_left_action = input_map.camera_left
	ship_camera.camera_up_action = input_map.camera_up
	ship_camera.camera_down_action = input_map.camera_down
	"""

