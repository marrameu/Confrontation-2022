extends VehicleShooting


func update_can_shoots():
	var ind : int = 0
	for can_shoot in can_shoots:
		can_shoots[ind] = (time_now >= next_times_to_fire[ind] and ammos[ind] >= 1)  #  and not owner.input.turboing
		ind += 1



@rpc(any_peer, call_local) func shoot_bullet(current_bullet : int, shoot_target := Vector3.ZERO) -> void:
	if owner.dead:
		return
	
	emit_signal("shot")
	# audio
	var audio_name : String = "Audio" + str(current_bullet + 1)
	get_node(audio_name).play()
	
	# ammo
	ammos[current_bullet] -= 1
	
	# fire rate
	next_times_to_fire[current_bullet] = time_now + 1.0 / fire_rates[current_bullet]
	
	# instance
	var bullet : Bullet
	bullet = bullets_scenes[current_bullet].instantiate()
	
	bullet.init(owner, owner.blue_team)
	
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
