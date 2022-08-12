extends Node

signal shot # per a la hud

var shoot_range := 1500


# Bullets
var bullets_scenes := { 0 : preload("res://src/Bullets/ShipBullet.tscn"), 1 : preload("res://src/Bullets/Ships/ShipBullet2.tscn")}

# Timers, fer-ho amb arrays?
var fire_rates := { 0 : 4.0, 1 : 1.0 }
var next_times_to_fire := { 0 : 0.0, 1 : 0.0 }
var time_now := 0.0

const MAX_AMMOS := { 0 : 50.0, 1: 4.0 }
var ammos := { 0 : 50.0, 1: 4.0 }
var auto_reload_ammo := { 0 : true, 1 : false}
var ease_ammos := { 0 : true, 1 : false }
var reload_per_sec := { 0 : 4.0 }
var not_eased_ammos := { 0 : 50.0 }


var wants_shoots := { 0: false, 1: false }
var can_shoots := { 0: true, 1: true }


var lock_missile_timer : Timer # no va, pq onready pq lscript canvia
var locking_target_to_missile := false
var target_locked := false
var locking_time : float = 1/fire_rates[1]
var lock_target : Spatial


func _process(delta : float) -> void:
	time_now += delta
	
	update_can_shoots()
	update_ammos(delta)
	
	if locking_target_to_missile:
		check_to_cancel_locking()


sync func shoot_bullet(current_bullet : int, shoot_target := Vector3.ZERO) -> void:
	if owner.dead or owner.state != owner.States.FLYING:
		return
	
	emit_signal("shot")
	# audio
	#(get_node("Audio" + str(current_bullet + 1)) as AudioStreamPlayer).play()
	
	# ammo
	ammos[current_bullet] -= 1
	
	# fire rate
	next_times_to_fire[current_bullet] = time_now + 1.0 / fire_rates[current_bullet]
	
	# instance
	var bullet : Bullet
	bullet = bullets_scenes[current_bullet].instance()
	
	bullet.init(owner, owner.pilot_man.blue_team)
	
	get_tree().current_scene.add_child(bullet)
	
	var shoot_from : Vector3 = owner.global_transform.origin # Canons
	bullet.global_transform.origin = shoot_from
	
	# dir
	if bullet is MissileBullet:
		if lock_target and target_locked:
			#target_locked = false
			bullet.target = lock_target
			return
	else:
		cancel_locking_target()
	
	if shoot_target:
		bullet.direction = (shoot_target - shoot_from).normalized()
		bullet.look_at(shoot_target, Vector3.UP)
	else:
		bullet.direction = owner.global_transform.basis.z
		bullet.look_at(owner.global_transform.origin + owner.global_transform.basis.z, Vector3.UP)


func most_frontal_enenmy(big_ships := false) -> Spatial: # poder rutllar es +o- fàcil (comparar si concorda amb l'histoiral)
	var closest_dist := -INF
	var most_frontal_enenmy : Spatial = null
	
	var enemies := []
	for ship in get_tree().get_nodes_in_group("Ships"):
		if ship.pilot_man:
			if ship.pilot_man.blue_team != owner.pilot_man.blue_team:
				enemies.append(ship)
	if big_ships:
		for big_ship in get_tree().get_nodes_in_group("BigShips"):
			if big_ship.blue_team != owner.pilot_man.blue_team:
				enemies.append(big_ship)
	
	for body in enemies:
		var direction := Vector3(body.global_transform.origin - owner.translation).normalized()
		var a = direction.dot(owner.global_transform.basis.z)
		
		if a > closest_dist:
			closest_dist = a
			most_frontal_enenmy = body
	
	return most_frontal_enenmy


func lock_target_to_missile():
	if owner.input.turboing:
		return
	
	if lock_target:
		locking_target_to_missile = true
		if $LockMissileTimer.is_stopped():
			$LockMissileTimer.wait_time = locking_time
			$LockMissileTimer.start()
	
	check_to_cancel_locking() # decideix ja si és darrere


func check_to_cancel_locking():
	if weakref(lock_target).get_ref():
		var direction := Vector3(lock_target.translation - owner.translation).normalized()
		var a = direction.dot(owner.global_transform.basis.z)
		if a < 0 or not can_shoots[1]:
			cancel_locking_target()
	else:
		cancel_locking_target()


func update_ammos(delta):
	var a : int = 0
	for ammo in ammos:
		if auto_reload_ammo[a]:
			if ease_ammos[a]:
				if not wants_shoots[a]:
					not_eased_ammos[a] += delta * reload_per_sec[a]
					ammos[a] = clamp(pow(not_eased_ammos[a]/MAX_AMMOS[a], 3.0) * MAX_AMMOS[a], 0, MAX_AMMOS[a])
				else:
					var b = pow(ammos[a]/MAX_AMMOS[a], 1.0/3.0)
					not_eased_ammos[a] = clamp(b*MAX_AMMOS[a], 0, MAX_AMMOS[a])
			else:
				if not wants_shoots[a]:
					ammos[a] += delta * reload_per_sec[a]
		a += 1


func update_can_shoots():
	var ind : int = 0
	for can_shoot in can_shoots:
		can_shoots[ind] = (time_now >= next_times_to_fire[ind] and ammos[ind] >= 1 and not owner.input.turboing)
		ind += 1


func cancel_locking_target():
	$LockMissileTimer.stop()
	locking_target_to_missile = false
	target_locked = false


func _on_LockMissileTimer_timeout():
	locking_target_to_missile = false
	target_locked = true
