extends KinematicBody

signal entered_ship

var pilot_man : PilotManager

var mouse_movement := Vector2()

# Move
var velocity := Vector3()
var direction := Vector3()

# Walk
var can_run := true
var gravity := -9.8 * 4
const MAX_SPEED := 6.75
const MAX_RUNNING_SPEED := 10
const ACCEL := 2
const DEACCEL := 6

# Jump
var jump_height := 14
var has_contact := false
onready var tail : RayCast = $Tail

# Slope
const MAX_SLOPE_ANGLE := 35

var dead := false


func _physics_process(delta):
	var joystick_movement := 0.0
	var yaw_strenght := joystick_movement + mouse_movement.x
	if yaw_strenght:
		rotate_yaw(yaw_strenght, delta)
	mouse_movement = Vector2.ZERO
	walk(delta)


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative * Settings.player_mouse_sensitivity


func rotate_yaw(strenght, delta):
	strenght *= delta
	rotate_y(-strenght)
	orthonormalize()


func walk(delta : float) -> void:
	# Reset player direction
	direction = Vector3()
	
	# Check input and change the direction
	var aim : Basis = get_global_transform().basis
	direction += aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	# Gravity and slopes
	if is_on_floor():
		has_contact = true
		var n = tail.get_collision_normal()
		var floor_angle := rad2deg(acos(n.dot(Vector3(0, 1, 0))))
		if floor_angle > MAX_SLOPE_ANGLE:
			velocity.y += gravity * delta
	else:
		if not tail.is_colliding():
			has_contact = false
		velocity.y += gravity * delta
	
	if has_contact and not is_on_floor():
		var _move_and_coll := move_and_collide(Vector3(0, -1, 0))
	
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0
	
	var speed : float
	if Input.is_action_pressed("run") and can_run:
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	# Max velocity
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	# Increase the velocity
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	# Jump (Before moving)
	if Input.is_action_just_pressed("jump") and has_contact:
		velocity.y = jump_height
		has_contact = false
		"""
		if get_node("Crouch").crouching:
			if get_tree().has_network_peer():
				get_node("Crouch").rpc("get_up")
			else:
				get_node("Crouch").get_up()
		"""
	
	# Move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), false, 4, deg2rad(MAX_SLOPE_ANGLE))
