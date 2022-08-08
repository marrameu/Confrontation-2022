extends Spatial

onready var init_cam_pos_x : float = -$CameraPosition.translation.x
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
var current_gun : Gun

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("change_view"):
		move_camera()


func _physics_process(delta):
	var joystick_movement := 0.0
	var pitch_strenght := (joystick_movement + mouse_movement.y) * rotate_speed_multipiler
	if pitch_strenght:
		rotate_pitch(pitch_strenght, delta)
	
	zooming = Input.is_action_pressed("zoom") and not owner.running
	update_zoom()
	
	process_shake()
	mouse_movement = Vector2.ZERO


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative * Settings.player_mouse_sensitivity


func move_camera() -> void:
	var current_x = $CameraPosition.translation.x
	if current_x > 0:
		var _new_x = tween.interpolate_property($CameraPosition, "translation:x", current_x, -init_cam_pos_x, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		var _new_x = tween.interpolate_property($CameraPosition, "translation:x", current_x, init_cam_pos_x, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	var _start = tween.start()


func rotate_pitch(strenght, delta):
	var camera_x_rot = clamp(rotation.x + strenght * delta, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
	rotation.x = camera_x_rot
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
	$StabilizeTimer.start()


func process_shake() -> void:
	# Si es mou el ratolí, talla-ho tot (reinicia), deixa de shake
	if abs(mouse_movement.y) > 2:#if mouse_movement.length() > 1:#input_movement.length() > 0: # menor que 1 pq així cal un gir prou gran per tallar el shake
		wants_to_stabilize = false
		shaking = false
	
	recoil_amount.x = original_cam_rot.x - rotation.x
	
	if shaking:
		var to = rotation.x + shake_amount.x
		rotation.x = clamp(lerp(rotation.x, to, 0.05), deg2rad(CAMERA_X_ROT_MIN - 10), deg2rad(CAMERA_X_ROT_MAX - 10))
		shake_amount.x = lerp(shake_amount.x, 0, 0.15)
		owner.rotation.y = lerp(owner.rotation.y, owner.rotation.y + shake_amount.y, 0.15)
		original_cam_rot.y = owner.rotation.y - shake_amount.y
		shake_amount.y = lerp(shake_amount.y, 0, 0.15)
	elif wants_to_stabilize: 
		if recoil_amount.x < 0.001: # ja s'ha estabilitzat
			wants_to_stabilize = false
			return
		var to = rotation.x + recoil_amount.x
		rotation.x = lerp(rotation.x, to, 0.15)
		owner.rotation.y = lerp(owner.rotation.y, owner.rotation.y - recoil_amount.y, 0.15)
		recoil_amount.y = lerp(recoil_amount.y, 0, 0.15)
		recoil_amount.x = lerp(recoil_amount.x, 0, 0.15)


func _on_StabilizeTimer_timeout():
	shaking = false
	# deixa de sacsejar, així doncs pot començar a estabilitzar-se

