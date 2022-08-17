extends Spatial

class_name ShipPhysics

var linear_force := Vector3(0, 0, 140)
var linear_force_turbo := Vector3(0, 0, 400)
var angular_force := Vector3(120, 120, 175) / 100.0

var applied_linear_force := Vector3()
var applied_angular_force := Vector3()

var desired_linear_force := Vector3()
var desired_angular_force := Vector3()

var angular_drag := 3.5
var linear_drag := 5.0 # temps en frenar/accelerar (inèrcia)
var NORMAL_LINEAR_DRAG := 6.25 # 7.5 potser
var DRIFTING_LINEAR_DRAG := 25
#si accelera de pressa (turbo) es redreça més de pressa (lerp)

var drifting := false

var stabilizing := false
var stabilized := false

var descense_vel := 0.0
var DESIRED_DESCENSE_VEL := 5.0
var ascense_vel := 0.0
var DESIRED_ASCENSE_VEL := 2.0


func _process(delta : float) -> void:
	var state : int = owner.state
	var States = owner.States
	
	match state:
		States.FLYING:
			if owner.dead:
				add_torque(Vector3(0, 0, 10), delta)
				return
			
			drifting = owner.input.drifting
			
			linear_drag = NORMAL_LINEAR_DRAG if !drifting else DRIFTING_LINEAR_DRAG
			# es canvia car aquí els motors "s'apaguen", en l'altre cas se suposa q quan els motors estan a zero
			# fan força per a frenar (aquí en egeuixen fent (si no, no pararia), però més a poc a poc)
			
			if not drifting:
				add_force(applied_linear_force, delta)
			else:
				add_force(Vector3.ZERO, delta) # apaga els motors del tot, sols roman la inèrcia
			
			add_torque(applied_angular_force, delta)
		
		States.LEAVING:
			owner.set_linear_velocity(Vector3(0, 2.5, 0)) 
		
		States.LANDING:
			# primer que abaixi la velocitat
			owner.linear_velocity = owner.linear_velocity.linear_interpolate(Vector3(0, -10, 0), 10 * delta)
			var rot_y := Vector3(0, rotation.y, 0)
			var rot_diff_y = rot_y - owner.rotation
			var target_angular_velocity_y = rot_diff_y * 0.1
			print(target_angular_velocity_y)
			owner.angular_velocity = owner.angular_velocity.linear_interpolate(rot_diff_y, 10 * delta)
			# ship.set_mode(RigidBody.MODE_KINEMATIC)
			"""
			if not stabilized and not stabilizing:
				_stabilize_rotation()
				ascense_vel = lerp(ascense_vel, DESIRED_ASCENSE_VEL, 0.1)
				ship.translation += Vector3(0, ascense_vel * delta, 0)
				
			elif stabilized:
				descense_vel = lerp(descense_vel, DESIRED_DESCENSE_VEL, 0.1)
				ship.translation += Vector3(0, -descense_vel * delta, 0)
			"""
			if get_node("Tail").is_colliding():
				owner.state = States.LANDED
				
				stabilizing = false
				stabilized = false
		
		States.LANDED:
			owner.set_mode(RigidBody.MODE_RIGID)


func set_physics_input(linear_input : Vector3, angular_input : Vector3, delta):
	var vel_length = owner.linear_velocity.length()
	
	var multiplier := 1.0
	
	"""
	if owner.input.throttle <= 0.5:
		multiplier = owner.input.throttle + 1
	elif owner.input.throttle > 0.5 and owner.input.throttle <= 1.0:
		multiplier = 2 - owner.input.throttle
	# soc jo o costa massa de girar?
	#elif owner.input.throttle > 1.0: # turbo
	#	multiplier = 1.5 - (0.5 * owner.input.throttle)
	"""
	
	
	if vel_length <= linear_force.z/2:
		multiplier = (1/linear_force.z * vel_length) + 1
	else: # vel_length <= 400: #vel.z <= 200 si vols que amb el turbo li costi el mateix
		multiplier = max(2 - (1/linear_force.z * vel_length), 0.5)
		# clamp pq a partir de 300 sigui 0,5 (si no, quan passés de 300 continuaria baixant fins q a 400 seria 0)
	
	#if owner.name == "PlayerShip":
	#	print(multiplier, "    ", vel_length)
	
	
	applied_angular_force = angular_input * angular_force * multiplier
	# lerp per a derrapar
	#var a = linear_input * linear_force
	#applied_linear_force = applied_linear_force.linear_interpolate(ship.global_transform.basis.xform(a), delta)
	
	var a = linear_input * linear_force
	applied_linear_force = a #applied_linear_force.linear_interpolate(ship.global_transform.basis.xform(a), delta)


func add_force(force : Vector3, delta : float):
	# lerp per a derrapar
	desired_linear_force = desired_linear_force.linear_interpolate(owner.global_transform.basis.xform(force), delta / linear_drag * 10)
	# lerp per a accelerar/frenar
	# desired_linear_force = desired_linear_force.linear_interpolate(desired_linear_force, delta / linear_drag * 10)
	owner.linear_velocity = desired_linear_force
	
	var b = owner.transform.basis
	var v_len = owner.linear_velocity.length()
	var v_nor = owner.linear_velocity.normalized()
	var vel : Vector3
	vel.z = b.z.dot(v_nor) * v_len
	vel.x = b.x.dot(v_nor) * v_len
	vel.y = b.y.dot(v_nor) * v_len
	get_node("../Debug/Pito").translation = vel


func add_torque(torque : Vector3, delta : float):
	#if drifting:
	#	torque *= DRIFTING_TORQUE_MULTIPLIER
	
	desired_angular_force = desired_angular_force.linear_interpolate(torque, delta / angular_drag * 10)
	owner.angular_velocity = owner.global_transform.basis.xform(desired_angular_force)


func _stabilize_rotation(time : float = 2.0) -> void:
	# Calcular el temps
	time *= abs(get_parent().rotation.x) if abs(get_parent().rotation.x) > abs(get_parent().rotation.z) else abs(get_parent().rotation.z / 2)
	time += 0.25
	
	$Tween.interpolate_property(get_parent(), "rotation", get_parent().rotation, Vector3(0, get_parent().rotation.y, 0), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	stabilizing = true

func _on_Tween_tween_all_completed():
	stabilized = true
