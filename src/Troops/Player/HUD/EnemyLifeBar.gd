extends VBoxContainer

onready var life_bar := $LifeBar
onready var nickname := $Nickname

var ray_range := 25.0

var target : Spatial


func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var viewport := get_viewport()
	var current_cam : Camera = viewport.get_camera()
	var space_state = get_parent().owner.get_world().direct_space_state
	
	if current_cam:
		var camera_width_center := viewport.get_visible_rect().size.x / 2
		var camera_height_center := viewport.get_visible_rect().size.y / 2
		
		var shoot_origin := current_cam.project_ray_origin(Vector2(camera_width_center, camera_height_center))
		var shoot_normal := shoot_origin + current_cam.project_ray_normal(Vector2(camera_width_center, camera_height_center)) * ray_range
		
		var result = space_state.intersect_ray(shoot_origin, shoot_normal, [get_parent().owner])
		if result:
			if result.collider.is_in_group("Troops"):
				target = result.collider
				nickname.text = target.nickname
				if target.pilot_man.blue_team:
					(life_bar as TextureProgress).tint_progress = Color("96006aff")
					nickname.add_color_override("font_color", "72a9ff")
				else:
					(life_bar as TextureProgress).tint_progress = Color("96ff0000")
					nickname.add_color_override("font_color", "ff7272")
				
				show()
				$Timer.start() # reinicia tota l'estona que hi ha target, així no s'acaba mai, es pot fer millor
	
	if target and weakref(target).get_ref():
		if not current_cam.is_position_behind(target.translation) and target.translation.distance_to(get_parent().owner.translation) <= ray_range:
			if target.get_node("HealthSystem").health == 0:
				hide()
				return
			
			show()
			life_bar.value = (float(target.get_node("HealthSystem").health) / float(target.get_node("HealthSystem").MAX_HEALTH)) * 100
			life_bar.rect_position = (current_cam as Camera).unproject_position(target.translation + Vector3(0, 2, 0)) - Vector2(life_bar.rect_size.x / 2, life_bar.rect_size.y / 2)
			nickname.rect_position = (current_cam as Camera).unproject_position(target.translation + Vector3(0, 2, 0)) - Vector2(nickname.rect_size.x / 2, nickname.rect_size.y / 2) - Vector2(0, 50)
			return
	
	hide()


func _on_Timer_timeout():
	target = null
