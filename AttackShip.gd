extends "res://BigShip.gd"


onready var target : Vector3

var can_move := false

var rel_position := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_ChangePosTimer_timeout()
	if blue_team:
		$TeamIndicator.material_override = blue_mat
	else:
		$TeamIndicator.material_override = red_mat


func _physics_process(delta):
	if not can_move:
		return
	
	target = rel_position
	target.x += get_node("/root/Level").middle_point
	
	move_and_collide(global_transform.basis.z * 100 * delta)
	turn(delta)
	if target.distance_to(translation) < 200 and $ChangePosTimer.is_stopped():
		$ChangePosTimer.wait_time = rand_range(4, 10)
		$ChangePosTimer.start()


func turn(delta):
	var desired_oirent : Transform = global_transform.looking_at(target, Vector3.UP)
	desired_oirent = desired_oirent.basis.rotated(desired_oirent.basis.y, deg2rad(180))
	
	$DesiredRot.global_transform.basis = desired_oirent.basis # No facis slerp a això pq si no fa ziga-zagues 
	$DesiredRot.global_transform.basis = $DesiredRot.global_transform.basis.slerp(desired_oirent.basis, 0.7 * delta) # No facis slerp a això pq si no fa ziga-zagues 
	
	var def_rot = $DesiredRot.rotation
	def_rot = def_rot.normalized()
	#def_rot.z = 0
	#owner.get_node("MeshInstance").rotation.z = 0
	
	# Per ser totalemnt correctes ->  x i y haurien de ser un Vector 2 normalitzat pq no puga girar més fort que el player i que sempre giri el màxim
	#pitch = def_rot.x
	#yaw = def_rot.y
	#roll = def_rot.z
	
	#DebugDraw.draw_line_3d(global_transform.origin, target, Color(1, 1, 0))
	
	# COM AL JOC ANTERIOR
	# AQUEST PRINT POT SER LA SOLUCIÓ A TOTS ELS MEUS PROBLEMES!!!
	# nse pq aqui cal ortonormalitzar i en les naus normals no :/
	$DesiredRot.global_transform.basis = global_transform.basis.orthonormalized().slerp(desired_oirent.basis, 0.7 * delta)
	#print(owner.get_node("MeshInstance").rotation)
	var uwu = $DesiredRot.rotation * 80 # no normalitzis la rotació del fill pq imagina't que li queda molt poc en tots els axis, faràs que es mogui molt i, vagi ebri
	#print(uwu)
	# es multiplica per un nombre gran pq l'slerp és molt petit
	# com més alt el nombre pel qual es multiplica millor, més precís (em penso) (potser fins i tot se centra de pressa a l'eix Y), però
	# no ha de ser massa alt, pq pot tornar a ser ebri (sobretot si l'Slerp és massa petit)
	if uwu.length() > 1: # ens assegurem q no sigui molt petit
		uwu = uwu.normalized()
	
	# no cal lerp? i pq al throttle sí?
	var roll = uwu.z
	
	var pitch = uwu.x
	var yaw = uwu.y
	
	var fotut = false
	
	var boost_multi = 1
	
	var up = false
	var down = false
	var right = false
	var left = false
	
	$ColDetectRays.get_node("ColDetectForward").cast_to = Vector3(0, 0, 150 * 1)
	$ColDetectRays.get_node("ColDetectDown").cast_to = Vector3(0, -75 * 1, 150 * 1)
	$ColDetectRays.get_node("ColDetectUp").cast_to = Vector3(0, 75 * 1, 150 * 1)
	$ColDetectRays.get_node("ColDetectRight").cast_to = Vector3(-75 * 1, 0, 150 * 1)
	$ColDetectRays.get_node("ColDetectLeft").cast_to = Vector3(75 * 1, 0, 150 * 1)
	
	"""
	# fer-ho amb la velocitat?
	var dist = owner.global_transform.origin.distance_to(target)
	var multi = clamp(((dist - a_partir_daqui_min)/(distancia_per_comencar_a_frenat - a_partir_daqui_min)), min_raycast_longitude, 1)
	#print(multi)
	owner.get_node("ColDetectForward").cast_to = Vector3(0, 0, 300 * multi)
	owner.get_node("ColDetectDown").cast_to = Vector3(0, -150 * multi, 300 * multi)
	owner.get_node("ColDetectUp").cast_to = Vector3(0, 150 * multi, 300 * multi)
	owner.get_node("ColDetectRight").cast_to = Vector3(-150 * multi, 0, 300 * multi)
	owner.get_node("ColDetectLeft").cast_to = Vector3(150 * multi, 0, 300 * multi)
	
	#owner.get_node("ColDetectForward").force_raycast_update()
	"""
	
	if ($ColDetectRays.get_node("ColDetectUp") as RayCast).is_colliding():
		DebugDraw.draw_line_3d(global_transform.origin, global_transform.origin+(global_transform.basis.xform($ColDetectRays.get_node("ColDetectUp").cast_to)), Color.blue)
		pitch = 1 # ves avall
		up = true
	if ($ColDetectRays.get_node("ColDetectDown") as RayCast).is_colliding():
		DebugDraw.draw_line_3d(global_transform.origin, global_transform.origin+(global_transform.basis.xform($ColDetectRays.get_node("ColDetectDown").cast_to)), Color.blue)
		pitch = -1 # vés amunt
		down = true
	# No elif pq si no, no es pot posar a true up i down
	
	# No toca ni a dalt ni a baix però si endavant
	if not down and not up and ($ColDetectRays.get_node("ColDetectForward") as RayCast).is_colliding():
		DebugDraw.draw_line_3d(global_transform.origin, global_transform.origin+(global_transform.basis.xform($ColDetectRays.get_node("ColDetectForward").cast_to)), Color.brown)
		pitch = -1 # Tant se val si -1 o 1, pq no toca enlloc
	elif down and up: # Toca a dalt i a baix
		if not ($ColDetectRays.get_node("ColDetectForward") as RayCast).is_colliding(): # No toca endavant
			pitch = 0
			# vés endavant
		else: # Toca per tot l'eix vertical
			if ($ColDetectRays.get_node("ColDetectUp") as RayCast).get_collision_point().distance_to(global_transform.origin) - ($ColDetectRays.get_node("ColDetectDown") as RayCast).get_collision_point().distance_to(global_transform.origin) > 20:
				if ($ColDetectRays.get_node("ColDetectUp") as RayCast).get_collision_point().distance_to(global_transform.origin) > ($ColDetectRays.get_node("ColDetectDown") as RayCast).get_collision_point().distance_to(global_transform.origin):
					pitch = -1
				else:
					pitch = 1
			else: # Si són a la mateixa distància, és a dir, una paret plana per exemple
				pitch = uwu.x
				
			#pitch = uwu.x # Això o el punt que quedi més lluny (amunt o avall)
			fotut = true
			# Toca amunt avall i davant
	
	
	# En un món ideal, la llargada dels RayCast dependria de la velocitat de la nau
	# dreta esquerra
	if ($ColDetectRays.get_node("ColDetectRight") as RayCast).is_colliding():
		DebugDraw.draw_line_3d(global_transform.origin, global_transform.origin+(global_transform.basis.xform($ColDetectRays.get_node("ColDetectRight").cast_to)), Color.blue)
		yaw = 1 # veé esquerra
		right = true
	# No elif pq si no, no es pot posar a true right i left
	if ($ColDetectRays.get_node("ColDetectLeft") as RayCast).is_colliding():
		DebugDraw.draw_line_3d(global_transform.origin, global_transform.origin+(global_transform.basis.xform($ColDetectRays.get_node("ColDetectLeft").cast_to)), Color.blue)
		yaw = -1 # vés dreta
		left = true
	
	# No toca ni a dreta ni a esq però si endavant
	if not left and not right and ($ColDetectRays.get_node("ColDetectForward") as RayCast).is_colliding():
		DebugDraw.draw_line_3d(global_transform.origin, global_transform.origin+(global_transform.basis.xform($ColDetectRays.get_node("ColDetectForward").cast_to)), Color.brown)
		yaw = 1 # Tant se val si -1 o 1, pq no toca enlloc
	elif right and left: # Toca dreta i esquerra
		if not ($ColDetectRays.get_node("ColDetectForward") as RayCast).is_colliding(): # No toca endavant
			yaw = 0
			# vés endavant
		else: # toca per tot arreu
			# Com més baix el número amb què es compara millor anirà a dintre de la CS (menys xocarà), però, segurament, li costi més d'entar
			if ($ColDetectRays.get_node("ColDetectRight") as RayCast).get_collision_point().distance_to(global_transform.origin) - ($ColDetectRays.get_node("ColDetectLeft") as RayCast).get_collision_point().distance_to(global_transform.origin) > 20:
				if ($ColDetectRays.get_node("ColDetectRight") as RayCast).get_collision_point().distance_to(global_transform.origin) > ($ColDetectRays.get_node("ColDetectLeft") as RayCast).get_collision_point().distance_to(global_transform.origin):
					yaw = -1
				else:
					yaw = 1
			else: # Si són a la mateixa distància, és a dir, una paret plana per exemple
				yaw = uwu.y
			if fotut: # Toca amunt dreta, esquerra i, a més, amunt, avall i endevant
				boost_multi = 0.25
	
	$DesiredRot.rotation = Vector3.ZERO
	
	rotation += (Vector3(pitch, yaw, roll) * delta / 3)
	
	# COM AL JOC ANTERIOR
	#owner.global_transform.basis = owner.global_transform.basis.slerp(desired_oirent.basis, 0.7 * delta)
	#owner.translation += owner.global_transform.basis.z * 100 * delta


func _on_ChangePosTimer_timeout():
	"""
	if get_node("/root/Level").middle_point < rand_range(-1750, -1250):
			if owner.blue_team:
				emit_signal("finished", "attack_cs")
			else:
				emit_signal("finished", "attack_enemy")
	elif get_node("/root/Level").middle_point > rand_range(1250, 1750):
		if not owner.blue_team:
			emit_signal("finished", "attack_cs")
	else:
	"""
	# si la dif és menor o major, que ataqui la nau capital (voltants)
	rel_position = Vector3(rand_range(-500, 500), rand_range(-350, 350) + 2000, rand_range(-700, 700))


func start():
	can_move = true
