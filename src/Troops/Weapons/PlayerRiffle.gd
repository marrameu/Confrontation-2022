extends Gun

var init_offset : Vector2


func _ready():
	init_offset = offset
	connect("shoot", owner.get_node("CameraBase"), "shake_camera", [self])


func _process(delta):
	offset = init_offset/2 if  owner.get_node("CameraBase").zooming else init_offset
	
	shooting = Input.is_action_pressed("shoot")
	var cam := get_viewport().get_camera()
	var cam_basis : Basis = cam.global_transform.basis
	$RayCast.global_transform.origin = cam.global_transform.origin
	global_transform.basis = cam_basis.get_euler() + Vector3(deg2rad(180), 0, 0)
