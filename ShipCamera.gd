extends Camera

var target : Position3D
var ship : Ship = null
var ship_wr : WeakRef

var starter_target_position := Vector3()

var rotate_speed := 90.0
var tp_rotate_speed := 90.0
var fp_rotate_speed := 90.0 * 100

# var move_speed_slerp := 90.0
# var rotate_speedslerp := 80.0

var horizontal_turn_move := 6.0
var vertical_turn_up_move := 6.0
var vertical_turn_down_move := 3.0

var tp_horizontal_turn_move := 6.0
var tp_vertical_turn_up_move := 6.0
var tp_vertical_turn_down_move := 3.0

var fp_horizontal_turn_move := 0.1
var fp_vertical_turn_up_move := 0.1
var fp_vertical_turn_down_move := 0.1

var forward_speed_divider := 100
var tp_forward_speed_divider := 35
var fp_forward_speed_divider := 3750

var zooming := false

var shake_amount = 0.02
var fp_shake_amount = 0.005
var tp_shake_amount = 0.05


# Input
var input_device := 0
var zoom_action := "zoom"
var look_behind_action := "look_behind"

var camera_right_action := "camera_right"
var camera_left_action := "camera_left"
var camera_up_action := "camera_up"
var camera_down_action := "camera_down"


var killer : Spatial


func _ready():
	init_cam()
	make_current()


func _process(delta):
	if not ship_wr or not ship_wr.get_ref():
		return
	
	if ship.dead:
		translation += transform.basis.z * 100 * delta
		if killer:
			var rot_transform = transform.looking_at(killer.translation, transform.basis.y)
			transform.basis = Basis(Quat(transform.basis).slerp(rot_transform.basis, 3 * delta))
		return
	
	if Input.is_action_just_pressed("change_cam"):
		Settings.first_person = !Settings.first_person
		init_cam()
	
	global_transform.origin = target.global_transform.origin # si és realitzat al physics prcess triga una mica a sguir la nau
	
	# comprovar amb una variable des de la mateixa nau
	if ship.input.turboing:
		shake_cam()
		Input.start_joy_vibration(input_device, 0, 0.5, 0.5)
	else:
		h_offset = 0
		v_offset = 0


func _physics_process(delta : float) -> void:
	if not ship_wr or not ship_wr.get_ref() or ship.dead:
		fov = 70
		return
	
	zooming = Input.is_action_pressed(zoom_action) and not ship.input.turboing
	if zooming:
		fov = lerp(fov, 40, .15)
	else:
		 #zooming = false TF?
		fov = lerp(fov, 70, .15)
	
	move_camera(delta)


func init_cam():
	if not ship:
		return
	
	if ship_wr and ship_wr.get_ref(): # si no, l'starter position es va canviant tota l'estona
		target.translation = starter_target_position
	
	# això es deu poder fer una mica millor
	if  Settings.first_person:
		target = ship.get_node("FPCameraPosition")
		rotate_speed = fp_rotate_speed
		horizontal_turn_move = fp_horizontal_turn_move
		vertical_turn_up_move = fp_vertical_turn_up_move
		vertical_turn_down_move = fp_vertical_turn_down_move
		forward_speed_divider = fp_forward_speed_divider
		shake_amount = fp_shake_amount
		
	else:
		target = ship.get_node("CameraPosition")
		rotate_speed = tp_rotate_speed
		horizontal_turn_move = tp_horizontal_turn_move
		vertical_turn_up_move = tp_vertical_turn_up_move
		vertical_turn_down_move = tp_vertical_turn_down_move
		forward_speed_divider = tp_forward_speed_divider
		shake_amount = tp_shake_amount
	
	ship_wr = weakref(ship);
	
	if not ship_wr.get_ref():
		return
	
	global_transform.origin = target.global_transform.origin
	global_transform.basis = target.global_transform.basis.get_euler()
	starter_target_position = target.translation


func shake_cam():
	h_offset = rand_range(-1.0, 1.0) * shake_amount
	v_offset = rand_range(-1.0, 1.0) * shake_amount


func move_camera(delta : float) -> void:
	global_transform.origin = target.global_transform.origin
	
	target.rotation_degrees = Vector3(0, 180, 0)
	global_transform.basis = target.global_transform.basis.get_euler()
	
	# té cap effecte açò?, potser s'hauria de fer diferent l'acció de mirar enrere
	global_transform.basis = Quat(global_transform.basis).slerp(Quat(target.global_transform.basis), rotate_speed * delta)
	update_target(delta)


func update_target(delta : float):
	var input := Vector2()
	
	input.x = target.get_node("../PlayerHUD").cursor_input.x if not Settings.controller_input else Input.get_action_strength(camera_right_action) - Input.get_action_strength(camera_left_action)
	input.y = target.get_node("../PlayerHUD").cursor_input.y if not Settings.controller_input else Input.get_action_strength(camera_up_action) - Input.get_action_strength(camera_down_action)
	
	# var viewport_size = get_tree().root.get_visible_rect().size
	
	input.x = clamp(input.x, -1, 1)
	input.y = clamp(input.y, -1, 1)
	
	horizontal_lean(target.get_node("../PlayerShipInterior"), -input.x, 5)
	horizontal_lean(target.get_node("../ShipMesh"), input.x)
	
	var horizontal := horizontal_turn_move * input.x
	var vertical := 0.0
	if input.y < 0.0:
		vertical = vertical_turn_up_move * input.y
	else:
		vertical = vertical_turn_down_move * input.y
	
	var b = target.owner.transform.basis
	var v_len = target.owner.linear_velocity.length()
	var v_nor = target.owner.linear_velocity.normalized()
	
	var vel : Vector3
	vel.z = b.z.dot(v_nor) * v_len
	
	
	var speed_forward = vel.z / forward_speed_divider
	
	# en lloc de fer l'angular amb l'input, fer-ho amb les físiques reals?
	var desired_position = starter_target_position + Vector3(-horizontal, vertical, -speed_forward)
	target.translation = target.translation.linear_interpolate(desired_position, delta)
	
	"""
	# temporal
	if not Settings.first_person:
		global_transform.origin = target.global_transform.origin # si és realitzat al physics prcess triga una mica a sguir la nau
"""

func horizontal_lean(target : Spatial, x_input : float, lean_limit : float = 45 , time : float = 0.03) -> void:
	var target_rotation : Vector3 = target.rotation_degrees
	target.rotation_degrees = Vector3(target_rotation.x, target_rotation.y, lerp(target_rotation.z, x_input * lean_limit, time))
