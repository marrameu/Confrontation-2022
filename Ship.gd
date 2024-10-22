extends RigidBody3D
class_name Ship

signal ship_died
signal killed_enemy
signal big_ship_shields_down
signal points_added

@export var red_mat : Material
@export var blue_mat : Material
@export var grey_mat : Material

@onready var input : Node = $Input # class per a linput i el physics
@onready var physics : Node = $Physics
@onready var shooting : Node = $Shooting

var pilot_man : PilotManager
var blue_team : bool

var is_player_or_ai := 0 # 1 player, 2 ia

var cam : Camera3D

var dead := false

enum States { LANDED, FLYING, LEAVING, LANDING }
var landing_areas := 0
var state := 0


func _ready():
	set_team_color()


func init(new_pilot_man : PilotManager):
	if pilot_man:
		exit_ship()
	
	pilot_man = new_pilot_man
	# blue_team = pilot_man.blue_team
	is_player_or_ai = 1 if pilot_man.is_player else 2
	if is_player_or_ai == 1:
		$PlayerHUD._make_visible(true)
		$AudioListener3D.make_current() # temporal, a vera com va
		input.set_script(preload("res://PlayerInput.gd"))
		shooting.set_script(preload("res://PlayerShipShooting.gd"))
	elif is_player_or_ai == 2:
		input.set_script(preload("res://ShipAIInput.gd"))
		input.set_physics_process(true) # WTF pq cal?
		shooting.set_script(preload("res://AIShipShooting.gd"))
		$StateMachine.active = true
	connect("ship_died",Callable(get_tree().current_scene,"_on_ship_died").bind(pilot_man))
	return true


func _process(delta):
	# no es pot fer des de l'input pq el godot peta si treus l'script des del mateix script
	if state == States.LANDED and is_player_or_ai == 1:
		if Input.is_action_just_pressed("interact"):
			$ExitTimer.start()
		elif Input.is_action_just_released("interact"):
			$ExitTimer.stop()
	
	$ShipMesh.visible = !Settings.first_person or dead or is_player_or_ai != 1
	$PlayerShipInterior.visible = Settings.first_person and not dead and is_player_or_ai == 1
	
	if state == States.FLYING:
		input_to_physics(delta)
		check_collisions(delta)
		update_thruster_flame()


func set_team_color():
	if blue_team:
		$ShipMesh/Cube.material_override = blue_mat
		$ShipMesh/Cube001.material_override = blue_mat
	else:
		$ShipMesh/Cube.material_override = red_mat
		$ShipMesh/Cube001.material_override = red_mat


func update_thruster_flame():
	
	#var Thruster = $ShipMesh/Thuster
	
	# 4.0 $ShipMesh/Thuster/Fire.emitting = !input.drifting
	
	var v_len = linear_velocity.length()
	#print ((v_len / 2) - 105)
	
	# 4.0$ShipMesh/Thuster/Fire.get_process_material().linear_accel = (v_len / 2) - 105
	#$ShipMesh/Thuster/Fire.get_process_material().damping = això no tinc ni idea de com fer-ho
	
	"""
	$ShipMesh/ThrusterFlame.TextureUniform2.gradient = $ShipMesh/ThrusterFlame.turbo_gradient if input.do_turbo else $ShipMesh/ThrusterFlame.normal_gradient
	$ShipMesh/ThrusterFlame.visible = !input.drifting
	var b = transform.basis
	var v_len = linear_velocity.length()
	var v_nor = linear_velocity.normalized()
	var vel : Vector3
	vel.z = b.z.dot(v_nor) * v_len
	$ShipMesh/ThrusterFlame.Speed = max(0.1, vel.z / 100)
	$ShipMesh/ThrusterFlame.Intensity = max(0.1, vel.z / 200)
	$ShipMesh/ThrusterFlame.Energy = max(0.1, vel.z / 100)
	"""
	
	


func input_to_physics(delta):
	var final_linear_input := Vector3(input.strafe, 0.0, input.throttle)
	var final_angular_input :=  Vector3(input.pitch, input.yaw, input.roll)
	physics.set_physics_input(final_linear_input, final_angular_input, delta)


func check_collisions(delta):
	if state == States.FLYING and get_colliding_bodies().size() > 0:
		for body in get_colliding_bodies():
			if not dead:
				#if not body.is_in_group("Bullets"):
				#Input.start_joy_vibration(0, 0, 1, 1)
				$HealthSystem.take_damage(delta * 8 * linear_velocity.length(), true) # s'hauria de fer la velocitat respecte el punt de col·lisió i no la total
			else:
				die() # Així si xoca quan fa voltes, en lloc de seguir fent voltes (que queda fatal), explota directament


func _on_HealthSystem_die(attacker : Node3D):
	dead = true
	print(name, " died")
	if attacker and is_player_or_ai == 1:
		cam.killer = (attacker)
	
	#if state == States.FLYING:
	# marca de dany?
	var t = Timer.new()
	t.set_wait_time(2)
	self.add_child(t)
	t.start()
	t.connect("timeout",Callable(self,"die"))
	#else:
	#	die()


func die():
	# explosió
	emit_signal("ship_died")
	queue_free()


func _on_damagable_hit():
	add_points(5) # fer q depengui de la bala
	if is_player_or_ai == 1:
		$PlayerHUD.on_damagable_hit()


func _on_enemy_died(attacker : Node): # passar tmb l'enemic
	if attacker == self:
		add_points(150)
		emit_signal("killed_enemy")
		if is_player_or_ai == 1:
			$PlayerHUD.on_enemy_died()
	else:
		add_points(75)


func leave() -> void:
	freeze = false
	state = States.LEAVING
	$LeaveTimer.start()
	$EnginesAudio.pitch_scale = 0.001
	var tween := create_tween()
	tween.tween_property($EnginesAudio, "pitch_scale", 1.0, 2.5)
	$EnginesAudio.play()


func _on_LeaveTimer_timeout():
	state = States.FLYING


func land():
	#if linear_velocity.length() > 50:
	#	return
	state = States.LANDING
	$EnginesAudio.stop()
	# ferho millor
	# physics.desired_linear_force = Vector3()
	# physics.desired_angular_force = Vector3()


func on_BigShip_shields_down(ship):
	emit_signal("big_ship_shields_down", ship)


func exit_ship(): # de moment, sols player
	if is_player_or_ai == 1:
		$PlayerHUD._make_visible(false)
		cam.ship = null
		get_tree().current_scene.spawn_player(position) # senyals
	elif is_player_or_ai == 2:
		$StateMachine.active = (false)
		get_tree().current_scene.spawn_ai_troop(String(pilot_man.name).trim_prefix("AIManager").to_int(), false, false, position) # senyals
	pilot_man = null
	input.set_script(preload("res://ShipInput.gd"))
	shooting.set_script(preload("res://src/Ships/ShipShooting.gd"))
	set_team_color()
	disconnect("ship_died",Callable(get_tree().current_scene,"_on_ship_died"))
	is_player_or_ai = 0


func add_points(points : int) -> void:
	if is_player_or_ai == 1:
		emit_signal("points_added", points)
	pilot_man.points += points


func _on_respawn() -> void:
	if is_player_or_ai == 1:
		$HealthSystem.take_damage(9999999, true)
