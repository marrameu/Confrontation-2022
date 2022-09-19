extends "res://src/Ships/ShipShooting.gd"

var shoot_action := "shoot"
var change_bullet_action := "change_bullet"
var lock_action := "lock"

var clear_target_press_time := 0.0

func _process(delta):
	if Input.is_action_just_pressed(lock_action): # fixar enemic
		lock_target = most_frontal_enenmy(true)
		clear_target_press_time = 0.0
		cancel_locking_target()
	if Input.is_action_pressed(lock_action): # desfixar enemic
		clear_target_press_time += delta
		if clear_target_press_time > 1:
			lock_target = null
	
	wants_shoots[0] = Input.is_action_pressed(shoot_action)
	wants_shoots[1] = Input.is_action_just_pressed("secondary_shoot")
	
	if wants_shoots[1]:
		if not target_locked:
			if lock_target:
				if not locking_target_to_missile:
					lock_target_to_missile() # SI POT, SI NO Q DISPARI
					if not locking_target_to_missile and can_shoots[1]: # és darrere
						shoot_bullet(1, shoot_target())
				else:
					if can_shoots[1]:
						shoot_bullet(1, shoot_target())
			else:
				if can_shoots[1]:
					shoot_bullet(1, shoot_target())
		else:
			if can_shoots[1]:
				shoot_bullet(1)
	elif wants_shoots[1] and ammos[1] < 1 and not $NoAmmoAudio.playing:
		pass #$NoAmmoAudio.play()
	
	if wants_shoots[0] and can_shoots[0]:
		shoot_bullet(0, shoot_target())
	elif wants_shoots[0] and ammos[0] < 1 and not $NoAmmoAudio.playing:
		pass#$NoAmmoAudio.play()
	
	if locking_target_to_missile:
		if not $LockingAudio.playing:
			pass#$LockingAudio.play()
	else:
		$LockingAudio.stop()
	
	super(delta)


func shoot_target() -> Vector3:
	# Camera3D
	var current_cam : Camera3D = owner.cam
	var space_state = get_parent().get_world_3d().direct_space_state
	
	var camera_width_center := 0.0
	var camera_height_center := 0.0
	var shoot_origin := Vector3()
	var shoot_normal := Vector3()
	var shoot_target := Vector3()
	
	if current_cam:
		var viewport = get_viewport()
		"""
		if get_tree().has_multiplayer_peer():
			viewport = get_node("/root/Main/Splitscreen")._renders[0].viewport
		else:
			viewport = get_node("/root/Main/Splitscreen")._renders[get_parent().number_of_player - 1].viewport
		"""
		camera_width_center = viewport.get_visible_rect().size.x / 2
		camera_height_center = viewport.get_visible_rect().size.y / 2
		
		# TEST
		var cursor_pos = owner.get_node("PlayerHUD").get_node("%Crosshair").position - owner.get_node("PlayerHUD").crosshair_center_pos# super.clamp(350)
		"""
		if LocalMultiplayer.number_of_players > 1:
			cursor_pos /= 2
		"""
		
		camera_width_center += cursor_pos.x
		camera_height_center += cursor_pos.y
		
		shoot_origin = current_cam.project_ray_origin(Vector2(camera_width_center, camera_height_center))
		shoot_normal = shoot_origin + current_cam.project_ray_normal(Vector2(camera_width_center, camera_height_center)) * shoot_range
		
		var query := PhysicsRayQueryParameters3D.create(shoot_origin, shoot_normal, 1, [get_parent()]) # manca establir els layers
		var result = space_state.intersect_ray(query)
		if result.is_empty():
			var ray_dir = current_cam.project_ray_normal(Vector2(camera_width_center, camera_height_center))
			shoot_target = shoot_origin + ray_dir * shoot_range
		else:
			shoot_target = result.position
		
	return shoot_target
