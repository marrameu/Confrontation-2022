extends State
class_name MoveState

# Move
var velocity := Vector3()

# Walk
# var can_run := true
var gravity := -9.8 * 4
@export var MAX_SPEED : float = 5.0
const ACCEL := 2
const DEACCEL := 6

# Jump
var jump_height := 14
var has_contact := false
@onready var tail : RayCast3D = owner.get_node("Tail")

# Slope
const MAX_SLOPE_ANGLE := 35


func initialize(enter_velocity):
	velocity = enter_velocity


func update(delta):
	# Check input and change the direction
	var aim : Basis = owner.get_global_transform().basis
	var direction : Vector3 = aim.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += aim.z * (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	
	direction.y = 0
	direction = direction.normalized()
	
	move(delta, MAX_SPEED, direction)


func move(delta : float, speed : float, direction : Vector3) -> void:
	# Gravity and slopes
	if owner.is_on_floor():
		has_contact = true
		var n = tail.get_collision_normal()
		var floor_angle := rad_to_deg(acos(n.dot(Vector3(0, 1, 0))))
		if floor_angle > MAX_SLOPE_ANGLE:
			velocity.y += gravity * delta
	else:
		if not tail.is_colliding():
			has_contact = false
		velocity.y += gravity * delta
	
	if has_contact and not owner.is_on_floor():
		var _move_and_coll = owner.move_and_collide(Vector3(0, -1, 0))
	
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0
	
	# Max velocity
	var target = direction * speed #(owner.get_global_transform().basis * speed) # solució temporal
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	# Increase the velocity
	temp_velocity = temp_velocity.lerp(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	# Move
	owner.set_velocity(velocity)
	owner.set_up_direction(Vector3(0, 1, 0))
	owner.set_floor_stop_on_slope_enabled(false)
	owner.set_max_slides(4)
	owner.set_floor_max_angle(deg_to_rad(MAX_SLOPE_ANGLE))
	owner.move_and_slide()
	velocity = owner.velocity
