extends State

export var max_speed := 6.0
export var rotation_speed := 8.0

var current_direction := Vector3()
var _velocity := Vector3.ZERO
var _snap := Vector3.DOWN * 0.05


func update(delta):
	if not owner.agent.is_navigation_finished():
		var target_global_position = owner.agent.get_next_location()
		var direction = owner.global_transform.origin.direction_to(target_global_position)
		var desired_velocity = direction * max_speed
		var steering = (desired_velocity - _velocity) * delta * 4.0
		_velocity += steering
		#agent.set_velocity(_velocity)
		_move(_velocity)
		if _velocity:
			if not owner.current_enemy:
				_orient_character_to_direction(current_direction)
		else:
			owner.get_node("AnimationTree").set("parameters/StateMachine/walk/move/blend_position", Vector2.ZERO)
	
	# AITroopShooting.gd
	if owner.current_enemy and weakref(owner.current_enemy).get_ref():
		if owner.wait_to_shoot:
			owner.get_node("%AIGun").shooting = false
			return
		if not owner.current_enemy.translation == owner.translation:
			owner.look_at(owner.current_enemy.global_translation, Vector3(0, 1, 0))
		owner.rotation = Vector3(0, owner.rotation.y + deg2rad(180), 0)
		owner.orthonormalize()
		owner.get_node("%AIGun").shooting = true
		return
	else:
		owner.current_enemy = null
		owner.get_node("%AIGun").shooting = false


func _move(velocity: Vector3) -> void:
	_velocity = owner.move_and_slide_with_snap(velocity, _snap, Vector3.UP)#, true)
	current_direction = Vector3(velocity.x, 0, velocity.z).normalized()


func _orient_character_to_direction(direction: Vector3) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction)
	owner.transform.basis = Basis(owner.transform.basis.get_rotation_quat().slerp(rotation_basis.get_rotation_quat(), get_physics_process_delta_time() * rotation_speed))
	owner.get_node("AnimationTree").set("parameters/StateMachine/walk/move/blend_position", Vector2(0, 1))#lerp(owner.get_node("AnimationTree").get("parameters/StateMachine/walk/move/blend_position"), Vector2(left_axis.z, left_axis.x), 20 * get_physics_process_delta_time()))
