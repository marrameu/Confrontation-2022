extends Button


var cp : CommandPost


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not is_visible_in_tree():
		return # no calen els calculs
	if cp and weakref(cp).get_ref():
		#if get_viewport().get_camera_3d().is_position_behind(cp.global_transform.origin)
		position = get_viewport().get_camera_3d().unproject_position(cp.global_transform.origin)
		position -= Vector2(size.x / 2, size.y / 2)
		update_button_color()
	else:
		queue_free()
		return
	
	if cp.is_in_group("SpaceCP"):
		visible = get_viewport().get_camera_3d().position.y > 2000
	else:
		visible = get_viewport().get_camera_3d().position.y < 2000
	
	disabled = get_parent().owner.waiting


func update_button_color() -> void:
	if cp.m_team == 0:
		add_theme_color_override("font_color", Color.WHITE)
	elif cp.m_team == 2:
		add_theme_color_override("font_color", Color("b4c7dc"))
	elif cp.m_team == 1:
		add_theme_color_override("font_color", Color("dcb4b4"))
