extends Node

# Ray
var ray_range := 15
var camera_width_center := 0.0
var camera_height_center := 0.0
var ray_origin := Vector3()
var ray_normal := Vector3()
var target_collider : Spatial

# Cameras
var ship_camera : Camera
var current_camera : Camera

# State
var is_in_a_vehicle := false
var current_vehicle : Spatial

# Multiplayer
var action := ""


func _process(delta : float) -> void:
	if get_tree().has_network_peer():
		if not is_network_master():
			return
	
	current_camera = get_viewport().get_camera()
	get_node("../PlayerHUD/TextureProgress").value = ($Timer.wait_time - $Timer.time_left) / $Timer.wait_time * 100
	get_node("../PlayerHUD/TextureProgress").visible = true if target_collider else false
	
	if Input.is_action_pressed("interact"):
		var viewport = get_viewport()
		camera_width_center = viewport.get_visible_rect().size.x / 2
		camera_height_center = viewport.get_visible_rect().size.y / 2
		
		ray_origin = current_camera.project_ray_origin(Vector2(camera_width_center, camera_height_center))
		ray_normal = ray_origin + current_camera.project_ray_normal(Vector2(camera_width_center, camera_height_center)) * ray_range
		
		var space_state = current_camera.get_world().direct_space_state
		var result = space_state.intersect_ray(ray_origin, ray_normal, [])
		if result:
			if not target_collider:
				var ship = result.collider
				if ship.is_in_group("Ships"):
					if not ship.is_player_or_ai == 1:
						$Timer.start()
						target_collider = ship
						return
			if result.collider == target_collider:
				if not result.collider.is_player_or_ai == 1:
					return
	
	$Timer.stop()
	target_collider = null


func _on_Timer_timeout():
	if target_collider.init(owner.pilot_man):
		owner.emit_signal("entered_ship", target_collider)
		target_collider = null
		owner.queue_free()
