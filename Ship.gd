extends RigidBody
class_name Ship

signal ship_died
signal killed_enemy

export var red_mat : Material
export var blue_mat : Material

onready var input : Node = $Input # class per a linput i el physics
onready var physics : Node = $Physics
onready var shooting : Node = $Shooting

var pilot_man : PilotManager

# var is_player := false
# var is_ai := false

var dead := false

enum States { LANDED, FLYING, LEAVING, LANDING }
var landing_areas := 0
var state := 0


func init(new_pilot_man : PilotManager):
	pilot_man = new_pilot_man
	set_team_color()


func _process(delta):
	if state == States.FLYING:
		input_to_physics(delta)
		check_collisions(delta)
		update_thruster_flame()


func set_team_color():
	if pilot_man.blue_team:
		$ShipMesh/Cube.material_override = blue_mat
		$ShipMesh/Cube001.material_override = blue_mat
	else:
		$ShipMesh/Cube.material_override = red_mat
		$ShipMesh/Cube001.material_override = red_mat


func update_thruster_flame():
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


func input_to_physics(delta):
	var final_linear_input := Vector3(input.strafe, 0.0, input.throttle)
	var final_angular_input :=  Vector3(input.pitch, input.yaw, input.roll)
	physics.set_physics_input(final_linear_input, final_angular_input, delta)


func check_collisions(delta):
	if state == States.FLYING and get_colliding_bodies().size() > 0:
		for body in get_colliding_bodies():
			#if not body.is_in_group("Bullets"):
			#Input.start_joy_vibration(0, 0, 1, 1)
			$HealthSystem.take_damage(delta * 8 * linear_velocity.length(), true) # s'hauria de fer la velocitat respecte el punt de col·lisió i no la total


func _on_HealthSystem_die(attacker : Node):
	dead = true
	print(name + "died")
	
	# animacions
	
	var t = Timer.new()
	t.set_wait_time(2)
	self.add_child(t)
	t.start()
	t.connect("timeout", self, "die")


func die():
	emit_signal("ship_died")
	queue_free()


func _on_damagable_hit():
	pass


func _on_enemy_died(attacker : Node): # passar tmb l'enemic
	if attacker == self:
		emit_signal("killed_enemy")


func leave() -> void:
	set_mode(RigidBody.MODE_RIGID)
	state = States.LEAVING
	$LeaveTimer.start()


func _on_LeaveTimer_timeout():
	state = States.FLYING


func land():
	state = States.LANDING
	# ferho millor
	physics.desired_linear_force = Vector3()
	physics.desired_angular_force = Vector3()
