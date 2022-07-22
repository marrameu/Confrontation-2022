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
					if not ship.pilot_man:
						$Timer.start()
						target_collider = ship
						return
			if result.collider == target_collider:
				return
	
	$Timer.stop()
	target_collider = null


func enter_ship(result):
	if get_tree().has_network_peer():
		rpc("change_ship_player", result.collider.get_path(), true, get_parent().online_id)
		get_node("../HealthSystem").rpc("update_components", false, false)
	else:
		change_ship_player(result.collider.get_path(), true, get_parent().online_id)
		get_node("../HealthSystem").update_components(false, false)
	
	result.collider.get_node("PlayerHUD/Center/CursorPivot/Cursor").rect_position = Vector2()
	result.collider.number_of_player = get_parent().number_of_player
	ship_camera.init(result.collider.get_node("CameraPosition"), get_parent().number_of_player)
	if get_tree().has_network_peer():
		get_parent().update_network_info()


func exit_ship() -> void:
	ship_camera.get_parent().remove_child(ship_camera)
	get_node("../CameraBase").add_child(ship_camera)
	ship_camera.translation = Vector3()
	ship_camera.rotation = Vector3()
	ship_camera.target = null
	
	current_vehicle.number_of_player = 0
	current_vehicle.set_linear_velocity(Vector3())
	current_vehicle.get_node("CameraPosition").translation = Vector3(0, 6, -30) # Change when adding slerp or other ships
	get_parent().global_transform.origin = current_vehicle.global_transform.origin
	
	if get_tree().has_network_peer():
		rpc("change_ship_player", current_vehicle.get_path(), false, 0)
		get_node("../HealthSystem").rpc("update_components", true, false)
	else:
		change_ship_player(current_vehicle.get_path(), false, 0)
		get_node("../HealthSystem").update_components(true, false)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if get_tree().has_network_peer():
		get_parent().update_network_info()


sync func change_ship_player(ship_path : NodePath, status : bool, id : int) -> void:
	is_in_a_vehicle = status
	if status == true:
		current_vehicle = get_node(ship_path)
	else:
		current_vehicle = null
	
	if get_node(ship_path):
		get_node(ship_path).is_player = status
		get_node(ship_path).player_id = id


func _on_Timer_timeout():
	target_collider.init(owner.pilot_man)
	owner.emit_signal("entered_ship", target_collider)
	target_collider = null
