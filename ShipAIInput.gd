extends "res://ShipInput.gd"


const THROTTLE_SPEED := 2.5

var target : Vector3 = Vector3(0, 0, 0)

var raycast_offset = 6
var detection_dist = 50

var ignore_collisions := false

var entered = false

var distancia_per_comencar_a_frenat := 500.0
var a_partir_daqui_min := 200.0

var min_raycast_longitude = 1

var raycast_multiplier = 1

var going_to_cs = false

var des_throttle := 1.0


func _process(delta):
	#DebugDraw.draw_line_3d(owner.global_transform.origin, target, Color(1, 1, 0))
	
	if owner.state == owner.States.LANDED:
		if $AILeaveTimer.is_stopped():
			$AILeaveTimer.connect("timeout",Callable(self,"_on_AILeaveTimer_timeout"))
			$AILeaveTimer.start()


func _physics_process(delta):
	entered = true # què?
	
	distancia_per_comencar_a_frenat = 700
	a_partir_daqui_min = 200
	min_raycast_longitude = 0.2
	going_to_cs = true
	
	move_forward(delta)
	if target:
		turn(delta)
	
	# roll = clamp(lerp(roll, 0, delta * ROLL_SPEED), -1, 1)


func move_forward(delta):
	var dist = owner.global_transform.origin.distance_to(target)
	var input_strenght : float = 0 # com si el jugador cliqués W/S
	update_throttle(des_throttle, delta) #dist - a_partir_daqui_min/distancia_per_comencar_a_frenat - a_partir_daqui_min, delta)


# Va una mica ebri!, però fa el fet. S'hauria de fer amb matemàtiques, passant la desired_oirent a local, com ho feia al del 2017 (amb l'Slerp però amb pitch, yaw i roll)
# Ja no va ebri!, però li costa de centrar-se del tot al voltant de l'eix Y, segurament és deu a fer-ho d'aquesta manera, amb físiques i amb un Slerp aproxiament
# no obstant això, aquest és el millor mètode que he trobat i val a dir que n'estic prou orgullós
func turn(delta):
	# return
	
	var desired_oirent : Transform3D = owner.global_transform.looking_at(target, Vector3.UP)
	desired_oirent = desired_oirent.basis.rotated(desired_oirent.basis.y, deg_to_rad(180))
	
	owner.get_node("ShipMesh").global_transform.basis = desired_oirent.basis # No facis slerp a això pq si no fa ziga-zagues 
	owner.get_node("ShipMesh").global_transform.basis = owner.get_node("ShipMesh").global_transform.basis.slerp(desired_oirent.basis, 0.7 * delta) # No facis slerp a això pq si no fa ziga-zagues 
	
	var def_rot = owner.get_node("ShipMesh").rotation
	def_rot = def_rot.normalized()
	#def_rot.z = 0
	#owner.get_node("MeshInstance3D").rotation.z = 0
	
	# Per ser totalemnt correctes ->  x i y haurien de ser un Vector 2 normalitzat pq no puga girar més fort que el player i que sempre giri el màxim
	#pitch = def_rot.x
	#yaw = def_rot.y
	#roll = def_rot.z
	
	# COM AL JOC ANTERIOR
	# AQUEST PRINT POT SER LA SOLUCIÓ A TOTS ELS MEUS PROBLEMES!!!
	owner.get_node("ShipMesh").global_transform.basis = owner.global_transform.basis.slerp(desired_oirent.basis, 0.7 * delta)
	#print(owner.get_node("MeshInstance3D").rotation)
	var uwu = owner.get_node("ShipMesh").rotation * 80 # no normalitzis la rotació del fill pq imagina't que li queda molt poc en tots els axis, faràs que es mogui molt i, vagi ebri
	#print(uwu)
	# es multiplica per un nombre gran pq l'slerp és molt petit
	# com més alt el nombre pel qual es multiplica millor, més precís (em penso) (potser fins i tot se centra de pressa a l'eix Y), però
	# no ha de ser massa alt, pq pot tornar a ser ebri (sobretot si l'Slerp és massa petit)
	if uwu.length() > 1: # ens assegurem q no sigui molt petit
		uwu = uwu.normalized()
	
	# no cal lerp? i pq al throttle sí?
	roll = uwu.z
	
	pitch = uwu.x
	yaw = uwu.y
	
	if not ignore_collisions:
		var fotut = false
		
		
		var up = false
		var down = false
		var right = false
		var left = false
		
		owner.get_node("ColDetects/ColDetectForward").target_position = Vector3(0, 0, 150 * raycast_multiplier)
		owner.get_node("ColDetects/ColDetectDown").target_position = Vector3(0, -75 * raycast_multiplier, 150 * raycast_multiplier)
		owner.get_node("ColDetects/ColDetectUp").target_position = Vector3(0, 75 * raycast_multiplier, 150 * raycast_multiplier)
		owner.get_node("ColDetects/ColDetectRight").target_position = Vector3(-75 * raycast_multiplier, 0, 150 * raycast_multiplier)
		owner.get_node("ColDetects/ColDetectLeft").target_position = Vector3(75 * raycast_multiplier, 0, 150 * raycast_multiplier)
		
		"""
		# fer-ho amb la velocitat?
		var dist = owner.global_transform.origin.distance_to(target)
		var multi = clamp(((dist - a_partir_daqui_min)/(distancia_per_comencar_a_frenat - a_partir_daqui_min)), min_raycast_longitude, 1)
		#print(multi)
		owner.get_node("ColDetectForward").target_position = Vector3(0, 0, 300 * multi)
		owner.get_node("ColDetectDown").target_position = Vector3(0, -150 * multi, 300 * multi)
		owner.get_node("ColDetectUp").target_position = Vector3(0, 150 * multi, 300 * multi)
		owner.get_node("ColDetectRight").target_position = Vector3(-150 * multi, 0, 300 * multi)
		owner.get_node("ColDetectLeft").target_position = Vector3(150 * multi, 0, 300 * multi)
		
		#owner.get_node("ColDetectForward").force_raycast_update()
		"""
		
		if (owner.get_node("ColDetects/ColDetectUp") as RayCast3D).is_colliding():
			DebugDraw.draw_line_3d(owner.global_transform.origin, owner.global_transform.origin+(owner.global_transform.basis * owner.get_node("ColDetects/ColDetectUp").target_position), Color.BLUE)
			pitch = 1 # ves avall
			up = true
		if (owner.get_node("ColDetects/ColDetectDown") as RayCast3D).is_colliding():
			DebugDraw.draw_line_3d(owner.global_transform.origin, owner.global_transform.origin+(owner.global_transform.basis * owner.get_node("ColDetects/ColDetectDown").target_position), Color.BLUE)
			pitch = -1 # vés amunt
			down = true
		# No elif pq si no, no es pot posar a true up i down
		
		# No toca ni a dalt ni a baix però si endavant
		if not down and not up and (owner.get_node("ColDetects/ColDetectForward") as RayCast3D).is_colliding():
			DebugDraw.draw_line_3d(owner.global_transform.origin, owner.global_transform.origin+(owner.global_transform.basis * owner.get_node("ColDetects/ColDetectForward").target_position), Color.BROWN)
			pitch = -1 # Tant se val si -1 o 1, pq no toca enlloc
		elif down and up: # Toca a dalt i a baix
			if not (owner.get_node("ColDetects/ColDetectForward") as RayCast3D).is_colliding(): # No toca endavant
				pitch = 0
				# vés endavant
			else: # Toca per tot l'eix vertical
				if (owner.get_node("ColDetects/ColDetectUp") as RayCast3D).get_collision_point().distance_to(owner.global_transform.origin) - (owner.get_node("ColDetects/ColDetectDown") as RayCast3D).get_collision_point().distance_to(owner.global_transform.origin) > 20:
					if (owner.get_node("ColDetects/ColDetectUp") as RayCast3D).get_collision_point().distance_to(owner.global_transform.origin) > (owner.get_node("ColDetects/ColDetectDown") as RayCast3D).get_collision_point().distance_to(owner.global_transform.origin):
						pitch = -1
					else:
						pitch = 1
				else: # Si són a la mateixa distància, és a dir, una paret plana per exemple
					pitch = uwu.x
					
				#pitch = uwu.x # Això o el punt que quedi més lluny (amunt o avall)
				fotut = true
				# Toca amunt avall i davant
		
		
		# En un món ideal, la llargada dels RayCast3D dependria de la velocitat de la nau
		# dreta esquerra
		if (owner.get_node("ColDetects/ColDetectRight") as RayCast3D).is_colliding():
			DebugDraw.draw_line_3d(owner.global_transform.origin, owner.global_transform.origin+(owner.global_transform.basis * owner.get_node("ColDetects/ColDetectRight").target_position), Color.BLUE)
			yaw = 1 # veé esquerra
			right = true
		# No elif pq si no, no es pot posar a true right i left
		if (owner.get_node("ColDetects/ColDetectLeft") as RayCast3D).is_colliding():
			DebugDraw.draw_line_3d(owner.global_transform.origin, owner.global_transform.origin+(owner.global_transform.basis * owner.get_node("ColDetects/ColDetectLeft").target_position), Color.BLUE)
			yaw = -1 # vés dreta
			left = true
		
		# No toca ni a dreta ni a esq però si endavant
		if not left and not right and (owner.get_node("ColDetects/ColDetectForward") as RayCast3D).is_colliding():
			DebugDraw.draw_line_3d(owner.global_transform.origin, owner.global_transform.origin+(owner.global_transform.basis * owner.get_node("ColDetects/ColDetectForward").target_position), Color.BROWN)
			yaw = 1 # Tant se val si -1 o 1, pq no toca enlloc
		elif right and left: # Toca dreta i esquerra
			if not (owner.get_node("ColDetects/ColDetectForward") as RayCast3D).is_colliding(): # No toca endavant
				yaw = 0
				# vés endavant
			else: # toca per tot arreu
				# Com més baix el número amb què es compara millor anirà a dintre de la CS (menys xocarà), però, segurament, li costi més d'entar
				if (owner.get_node("ColDetects/ColDetectRight") as RayCast3D).get_collision_point().distance_to(owner.global_transform.origin) - (owner.get_node("ColDetects/ColDetectLeft") as RayCast3D).get_collision_point().distance_to(owner.global_transform.origin) > 20:
					if (owner.get_node("ColDetects/ColDetectRight") as RayCast3D).get_collision_point().distance_to(owner.global_transform.origin) > (owner.get_node("ColDetects/ColDetectLeft") as RayCast3D).get_collision_point().distance_to(owner.global_transform.origin):
						yaw = -1
					else:
						yaw = 1
				else: # Si són a la mateixa distància, és a dir, una paret plana per exemple
					yaw = uwu.y
				if fotut: # Toca amunt dreta, esquerra i, a més, amunt, avall i endevant
					pass
					#boost_multi = 0.25
		
	
	owner.get_node("ShipMesh").rotation = Vector3.ZERO
	
	# COM AL JOC ANTERIOR
	#owner.global_transform.basis = owner.global_transform.basis.slerp(desired_oirent.basis, 0.7 * delta)
	#owner.position += owner.global_transform.basis.z * 100 * delta


func _on_AILeaveTimer_timeout():
	owner.leave()
