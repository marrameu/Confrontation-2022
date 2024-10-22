extends VBoxContainer

@onready var life_bar := $LifeBar
@onready var nickname := $Nickname

var ray_range := 100.0

var target : Node3D


func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var viewport := get_viewport()
	var current_cam : Camera3D = viewport.get_camera_3d()
	var space_state = owner.owner.get_world_3d().direct_space_state
	
	if current_cam:
		var camera_width_center := viewport.get_visible_rect().size.x / 2
		var camera_height_center := viewport.get_visible_rect().size.y / 2
		
		var shoot_origin := current_cam.project_ray_origin(Vector2(camera_width_center, camera_height_center))
		var shoot_normal := shoot_origin + current_cam.project_ray_normal(Vector2(camera_width_center, camera_height_center)) * ray_range
		
		var query := PhysicsRayQueryParameters3D.create(shoot_origin, shoot_normal, 1, [get_parent().owner])
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider.is_in_group("Damagable"):
				target = result.collider
				if target.is_in_group("Troops"):
					nickname.text = target.name #.nickname (per debug)
					if target.blue_team:
						(life_bar as TextureProgressBar).tint_progress = Color("96006aff")
						nickname.add_theme_color_override("font_color", "72a9ff")
					else:
						(life_bar as TextureProgressBar).tint_progress = Color("96ff0000")
						nickname.add_theme_color_override("font_color", "ff7272")
				else:
					nickname.text = target.name
					(life_bar as TextureProgressBar).tint_progress = Color.WHITE
					nickname.add_theme_color_override("font_color", Color.WHITE)
				
				show()
				$Timer.start() # reinicia tota l'estona que hi ha target, així no s'acaba mai, es pot fer millor
	
	if target and weakref(target).get_ref():
		if not current_cam.is_position_behind(target.global_transform.origin):
			if target.global_transform.origin.distance_to(owner.owner.position) <= 500: # potser ni caldria
				if target.get_node("HealthSystem").health == 0:
					hide()
					return
				
				show() # no caldria
				life_bar.value = (float(target.get_node("HealthSystem").health) / float(target.get_node("HealthSystem").MAX_HEALTH)) * 100
				position = (current_cam as Camera3D).unproject_position(target.global_transform.origin + Vector3(0, 2, 0)) - Vector2(life_bar.size.x / 2, life_bar.size.y / 2)
				return
	
	hide()


func _on_Timer_timeout():
	target = null
