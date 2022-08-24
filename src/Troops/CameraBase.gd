extends Spatial

onready var init_h_offset : float = -$CameraPosition.translation.x
onready var tween : Tween = $Tween

var mouse_movement := Vector2()

const CAMERA_X_ROT_MAX := 50
const CAMERA_X_ROT_MIN := -60

var zooming := false
var rotate_speed_multipiler := 1.0


# recoil
var shaking := false
var wants_to_stabilize := false
var shake_amount := Vector2()
var recoil_amount := Vector2()
var original_cam_rot := Vector2()
var cam_yaw_at_last_shot := 0.0
var current_gun : Gun


export var player_path : NodePath


var killer : Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	$PuppetCamPos.translation = $CameraPosition.translation
	$RayCast.cast_to = $PuppetCamPos.translation
	$RayCast.add_exception(get_node(player_path)) # pq no va? -> mirar errors debug


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not get_node_or_null(player_path):
		$"%PlayerTroopCam".fov = 70.0
		return
	if Input.is_action_just_pressed("change_view") and get_node(player_path).can_aim:
		move_camera()
	check_collisions() # pot anar aquí en lloc de al physics pq el raycast sols sactualitza al physsics
	#rotation = get_node(player_path).global_transform.basis.get_euler()


func _physics_process(delta):
	if not get_node_or_null(player_path):
		return
	
	if get_node(player_path).dead:
		translation += transform.basis.z * 2 * delta # o cap a endavant?
		if weakref(killer).get_ref():
			var rot_transform = transform.looking_at(killer.translation, transform.basis.y)
			transform.basis = Basis(Quat(transform.basis).slerp(rot_transform.basis, 3 * delta))
			rotation.z = 0
		return
	
	translation = translation.linear_interpolate(get_node(player_path).get_node("CamPos").global_translation, 0.25 * delta * 60)
	
	var joystick_movement := 0.0
	var pitch_strenght := (-joystick_movement - mouse_movement.y) * rotate_speed_multipiler
	var yaw_strenght : float = (joystick_movement + mouse_movement.x) * rotate_speed_multipiler
	if pitch_strenght and get_node(player_path).can_aim:
		rotate_pitch(pitch_strenght, delta)
	if yaw_strenght and get_node(player_path).can_aim:
		rotate_yaw(yaw_strenght, delta)
	
	zooming = Input.is_action_pressed("zoom") and get_node(player_path).can_shoot #owner.running
	update_zoom()
	
	process_shake()
	mouse_movement = Vector2.ZERO
	
	$RayCast.cast_to = $PuppetCamPos.translation


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative * Settings.player_mouse_sensitivity


func rotate_pitch(strenght, delta):
	var camera_x_rot = clamp(rotation.x + strenght * delta, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
	rotation.x = camera_x_rot
	orthonormalize()


func rotate_yaw(strenght, delta):
	strenght *= delta
	rotate_y(-strenght)
	orthonormalize()


func update_zoom() -> void:
	get_viewport().get_camera().fov = lerp(get_viewport().get_camera().fov, 70 / 2.0, .25) if zooming else lerp(get_viewport().get_camera().fov, 70.0, .25)
	rotate_speed_multipiler = 0.5 if zooming else 1.0
	#get_parent().joystick_sensitivity = init_joystick_sensitivity / 3 if zooming else init_joystick_sensitivity


func shake_camera(gun : Gun) -> void:
	var shake_force := gun.recoil_force
	current_gun = gun
	# Els eixos estan invertits per a la rotació
	# En un futur moure la càmara enrere. TF?
	if not shaking:
		shaking = true
		original_cam_rot.x = rotation.x
	#if get_parent().get_node("Crouch").crouching:
	#	multiplier = 0.15
	var multiplier := 0.5 if zooming else 1.0
	shake_amount.x = -0.025 * multiplier * shake_force.x
	if randf() > 0.5:
		shake_amount.y = rand_range(0.006 * multiplier * shake_force.y, 0.01 * multiplier * shake_force.y)
	else:
		shake_amount.y = rand_range(-0.01 * multiplier * shake_force.y, -0.006 * multiplier * shake_force.y)
	if shake_amount.y + recoil_amount.y > (0.02 * shake_force.y * multiplier) or shake_amount.y + recoil_amount.y < (-0.02 * shake_force.y * multiplier):
		shake_amount.y = 0
	recoil_amount.y += shake_amount.y
	wants_to_stabilize = true
	cam_yaw_at_last_shot = rotation.x
	$StabilizeTimer.start()


func process_shake() -> void:
	# Si es mou el ratolí, talla-ho tot (reinicia), deixa de shake
	# hi ha hagut un moviment fort? o, si no, s'ha mogut molt però a poc a poc des que va deixar de siparar (sorbetot per no haver de canviar el valor del timer, cosa q segurament caldrà fer per a les armes com snipers i llançamíssils)
	if abs(mouse_movement.y) > 0.5:# or abs(cam_yaw_at_last_shot - rotation.x) > deg2rad(5):#if mouse_movement.length() > 1:#input_movement.length() > 0: # menor que 1 pq així cal un gir prou gran per tallar el shake
		wants_to_stabilize = false
		shaking = false
	
	recoil_amount.x = original_cam_rot.x - rotation.x
	
	if shaking:
		var to = rotation.x + shake_amount.x
		rotation.x = clamp(lerp(rotation.x, to, 0.05), deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
		shake_amount.x = lerp(shake_amount.x, 0, 0.15)
		rotation.y = lerp(rotation.y, rotation.y + shake_amount.y, 0.15)
		original_cam_rot.y = rotation.y - shake_amount.y
		shake_amount.y = lerp(shake_amount.y, 0, 0.15)
	elif wants_to_stabilize: 
		if recoil_amount.x < 0.001: # ja s'ha estabilitzat
			wants_to_stabilize = false
			return
		var to = rotation.x + recoil_amount.x
		rotation.x = lerp(rotation.x, to, 0.15)
		rotation.y = lerp(rotation.y, rotation.y - recoil_amount.y, 0.15)
		recoil_amount.y = lerp(recoil_amount.y, 0, 0.15)
		recoil_amount.x = lerp(recoil_amount.x, 0, 0.15)


func _on_StabilizeTimer_timeout():
	shaking = false
	# deixa de sacsejar, així doncs pot començar a estabilitzar-se


func move_camera() -> void:
	var current_h_offset = $PuppetCamPos.translation.x
	if current_h_offset > 0:
		var _new_x = tween.interpolate_property($PuppetCamPos, "translation:x", current_h_offset, -init_h_offset, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		var _new_x = tween.interpolate_property($PuppetCamPos, "translation:x", current_h_offset, init_h_offset, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	var _start = tween.start()


func check_collisions(): # hauria de ser diferent per a quan mor
	if $RayCast.is_colliding():
		#print($RayCast.get_collider(), randi())
		$CameraPosition.translation = $CameraPosition.translation.linear_interpolate(to_local($RayCast.get_collision_point()), 0.2)
		$CameraPosition.global_translation += Vector3.ONE / 10 * $CameraPosition.global_translation.direction_to(translation)
	else:
		$CameraPosition.translation = $PuppetCamPos.translation
