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
		#if get_viewport().get_camera().is_position_behind(cp.global_transform.origin)
		rect_position = get_viewport().get_camera().unproject_position(cp.global_transform.origin)
		rect_position -= Vector2(rect_size.x / 2, rect_size.y / 2)
		update_button_color()
	#else:
	#	queue_free()


func update_button_color() -> void:
	if cp.m_team == 0:
		add_color_override("font_color", Color.white)
	elif cp.m_team == 2:
		add_color_override("font_color", Color("b4c7dc"))
	elif cp.m_team == 1:
		add_color_override("font_color", Color("dcb4b4"))
