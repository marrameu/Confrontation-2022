extends State

@export var max_speed := 6.0
@export var rotation_speed := 8.0

var current_direction := Vector3()
var _velocity := Vector3.ZERO
var _snap := Vector3.DOWN * 0.05


func enter():
	owner.agent.set_target_location(owner.agent.get_target_location())


func handle_input(event):
	if event.is_action_pressed("test"):
		emit_signal("finished", "roll")


func update(delta):
	if not owner.agent.is_navigation_finished():
		var target_global_position = owner.agent.get_next_location()
		var direction = owner.global_transform.origin.direction_to(target_global_position)
		var desired_velocity = direction * max_speed
		var steering = (desired_velocity - _velocity) * delta * 4.0
		_velocity += steering
		_move(_velocity)
		if _velocity: #.length() > 0.1:
			if not owner.current_enemy:
				_orient_character_to_direction(current_direction)
	else:
		owner.get_node("AnimationTree").set("parameters/StateMachine/walk/move/blend_position", Vector2.ZERO)
	
	# AITroopShooting.gd
	if owner.current_enemy and weakref(owner.current_enemy).get_ref():
		if owner.wait_to_shoot:
			owner.get_node("%AIGun").shooting = false
			return
		if not owner.current_enemy.position == owner.position:
			owner.look_at(owner.current_enemy.global_position, Vector3(0, 1, 0))
		owner.rotation = Vector3(0, owner.rotation.y + deg_to_rad(180), 0)
		owner.orthonormalize()
		owner.get_node("%AIGun").shooting = true
		return
	else:
		owner.current_enemy = null
		owner.get_node("%AIGun").shooting = false


func _move(velocity: Vector3) -> void:
	owner.set_velocity(velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `_snap`
	owner.set_up_direction(Vector3.UP)
	owner.move_and_slide()
	_velocity = owner.velocity#, true)
	print(_velocity)
	current_direction = Vector3(velocity.x, 0, velocity.z).normalized()


func _orient_character_to_direction(direction: Vector3) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction)
	owner.transform.basis = Basis(owner.transform.basis.get_rotation_quaternion().slerp(rotation_basis.get_rotation_quaternion(), get_physics_process_delta_time() * rotation_speed))
	owner.get_node("AnimationTree").set("parameters/StateMachine/walk/move/blend_position", Vector2(0, 1))#lerp(owner.get_node("AnimationTree").get("parameters/StateMachine/walk/move/blend_position"), Vector2(left_axis.z, left_axis.x), 20 * get_physics_process_delta_time()))
