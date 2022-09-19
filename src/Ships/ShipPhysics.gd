extends Node3D

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

enum States { LANDED, FLYING, LEAVING, LANDING } # solució temporal Godot 4.0


func _process(delta : float) -> void:
	var state : int = owner.state
	
	match state:
		States.FLYING:
			if owner.dead:
				apply_torque(Vector3(0, 0, 10), delta)
				return
			
			drifting = owner.input.drifting
			
			linear_drag = NORMAL_LINEAR_DRAG if !drifting else DRIFTING_LINEAR_DRAG
			# es canvia car aquí els motors "s'apaguen", en l'altre cas se suposa q quan els motors estan a zero
			# fan força per a frenar (aquí en egeuixen fent (si no, no pararia), però més a poc a poc)
			
			if not drifting:
				apply_force(delta, applied_linear_force)
			else:
				apply_force(delta, Vector3.ZERO) # apaga els motors del tot, sols roman la inèrcia
			
			apply_torque(applied_angular_force, delta)
		
		States.LEAVING:
			owner.set_linear_velocity(Vector3(0, 2.5, 0)) 
		
		States.LANDING:
			# primer que abaixi la velocitat
			owner.linear_velocity = owner.linear_velocity.lerp(Vector3(0, -10, 0), 10 * delta)
			var rot_y := Vector3(0, rotation.y, 0)
			var rot_diff_y = rot_y - owner.rotation
			var target_angular_velocity_y = rot_diff_y * 0.1
			print(target_angular_velocity_y)
			owner.angular_velocity = owner.angular_velocity.lerp(rot_diff_y, 10 * delta)
			# ship.set_mode(RigidBody3D.FREEZE_MODE_KINEMATIC)
			"""
			if not stabilized and not stabilizing:
				_stabilize_rotation()
				ascense_vel = lerp(ascense_vel, DESIRED_ASCENSE_VEL, 0.1)
				ship.position += Vector3(0, ascense_vel * delta, 0)
				
			elif stabilized:
				descense_vel = lerp(descense_vel, DESIRED_DESCENSE_VEL, 0.1)
				ship.position += Vector3(0, -descense_vel * delta, 0)
			"""
			if get_node("Tail").is_colliding():
				owner.state = owner.States.LANDED
				
				stabilizing = false
				stabilized = false
		
		States.LANDED:
			owner.freeze = true


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
	#applied_linear_force = applied_linear_force.lerp(ship.global_transform.basis * a, delta)
	
	var a = linear_input * linear_force
	applied_linear_force = a #applied_linear_force.lerp(ship.global_transform.basis * a, delta)


func apply_force(delta : float, force : Vector3):
	# lerp per a derrapar
	desired_linear_force = desired_linear_force.lerp(owner.global_transform.basis * force, delta / linear_drag * 10)
	# lerp per a accelerar/frenar
	# desired_linear_force = desired_linear_force.lerp(desired_linear_force, delta / linear_drag * 10)
	owner.linear_velocity = desired_linear_force
	
	var b = owner.transform.basis
	var v_len = owner.linear_velocity.length()
	var v_nor = owner.linear_velocity.normalized()
	var vel : Vector3
	vel.z = b.z.dot(v_nor) * v_len
	vel.x = b.x.dot(v_nor) * v_len
	vel.y = b.y.dot(v_nor) * v_len
	get_node("../Debug/Pito").position = vel


func apply_torque(torque : Vector3, delta : float):
	#if drifting:
	#	torque *= DRIFTING_TORQUE_MULTIPLIER
	
	desired_angular_force = desired_angular_force.lerp(torque, delta / angular_drag * 10)
	owner.angular_velocity = owner.global_transform.basis * desired_angular_force


func _stabilize_rotation(time : float = 2.0) -> void:
	# Calcular el temps
	time *= abs(get_parent().rotation.x) if abs(get_parent().rotation.x) > abs(get_parent().rotation.z) else abs(get_parent().rotation.z / 2)
	time += 0.25
	
	$Tween.interpolate_property(get_parent(), "rotation", get_parent().rotation, Vector3(0, get_parent().rotation.y, 0), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	stabilizing = true

func _on_Tween_tween_all_completed():
	stabilized = true
