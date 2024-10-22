extends Node

# Ray
var ray_range := 15
var camera_width_center := 0.0
var camera_height_center := 0.0
var ray_origin := Vector3()
var ray_normal := Vector3()
var target_collider : Node3D

# Cameras
var ship_camera : Camera3D
var current_camera : Camera3D

# State
var is_in_a_vehicle := false
var current_vehicle : Node3D

# Multiplayer
var action := ""

# UI
@export var interaction_progress_path : NodePath
@onready var interaction_progress : TextureProgressBar = get_node(interaction_progress_path)


func _process(delta : float) -> void:
	current_camera = get_viewport().get_camera_3d()
	interaction_progress.value = ($Timer.wait_time - $Timer.time_left) / $Timer.wait_time * 100
	interaction_progress.visible = true if target_collider else false
	
	if Input.is_action_just_pressed("interact") or (target_collider and Input.is_action_pressed("interact")): # pq no cicli
		var viewport = get_viewport()
		camera_width_center = viewport.get_visible_rect().size.x / 2
		camera_height_center = viewport.get_visible_rect().size.y / 2
		
		ray_origin = current_camera.project_ray_origin(Vector2(camera_width_center, camera_height_center))
		ray_normal = ray_origin + current_camera.project_ray_normal(Vector2(camera_width_center, camera_height_center)) * ray_range
		
		var space_state = current_camera.get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_normal, 32768)
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var result = space_state.intersect_ray(query)
		if result:
			var collider = result.collider
			if not target_collider:
				if collider.can_interact(owner):
					$Timer.start()
					target_collider = collider
					return
			elif collider == target_collider:
				if target_collider.can_interact(owner):
					return
	
	$Timer.stop()
	target_collider = null


func _on_Timer_timeout():
	target_collider.interact(owner)
	
	play_sound()
	
	if target_collider.owner.is_in_group("Ships"):
		owner.emit_signal("entered_ship", target_collider.owner)
		owner.queue_free() # canvi estat
	elif target_collider.owner.is_in_group("Vehicle"):
		owner.emit_signal("entered_vehicle", target_collider.owner)
		owner.queue_free() # canvi estat
	
	target_collider = null


func play_sound():
	var audio : AudioStreamPlayer = AudioStreamPlayer.new()
	audio.set_stream(preload("res://assets/audio/interaction.wav"))
	audio.connect("finished",Callable(audio,"queue_free"))
	get_tree().current_scene.add_child(audio)
	audio.play()
