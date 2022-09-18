extends Gun

var init_offset : Vector2

@export var continuous := true

@onready var cam_base := get_tree().current_scene.get_node("%CameraBase")

@onready var original_rot : Vector3 = $Mesh.rotation


func _ready():
	$"%Reload".visible = !reload_per_sec
	init_offset = offset
	connect("shoot",Callable(get_tree().current_scene.get_node("CameraBase"),"shake_camera").bind(self))


func _process(delta):
	if not active:
		#$HUD/Crosshair/AnimationPlayer.current_animation = "RESET"
		return
	
	$HUD.get_node("%Crosshair/AnimationTree").set("parameters/conditions/!zooming", !cam_base.zooming)
	$HUD.get_node("%Crosshair/AnimationTree").set("parameters/conditions/zooming", cam_base.zooming)
	
	$"%Ammo".value = ammo/MAX_AMMO*100
	if !reload_per_sec:
		$"%Reload".value = ammo_to_reload/MAX_RELOAD_AMMO*100
	
	offset = init_offset/2 if get_tree().current_scene.get_node("CameraBase").zooming else init_offset
	
	if not continuous:
		shooting = owner.can_shoot and Input.is_action_just_pressed("shoot")
	else:
		shooting = owner.can_shoot and Input.is_action_pressed("shoot")
	
	var cam := get_viewport().get_camera_3d()
	var cam_basis : Basis = cam.global_transform.basis
	
	$RayCast3D.global_transform.origin = cam.global_transform.origin #- cam.global_transform.basis.z * 5 # distància fins al jugador
	$RayCast3D.global_transform.basis = Basis(Quaternion(cam_basis.get_euler()))


func _physics_process(delta):
	$HUD.get_node("%Crosshair").modulate = Color("ffffff") if owner.can_shoot else Color("3fffffff")
	if not owner.can_shoot: #or not get_viewport().get_camera_3d().owner.zooming:
		$Mesh.rotation = original_rot
		return
	
	$RayCast3D.force_raycast_update()
	if $RayCast3D.is_colliding():
		$Mesh.look_at($RayCast3D.get_collision_point(), Vector3.UP)
		# $Mesh.rotate($Mesh.transform.basis.y, 180)
		"""var new_mesh = MeshInstance3D.new()
		new_mesh.mesh = BoxMesh.new()
		get_tree().current_scene.add_child(new_mesh)
		new_mesh.position = $RayCast3D.get_collision_point()"""
	else:
		var cam := get_viewport().get_camera_3d()
		var cam_basis : Basis = cam.global_transform.basis
		$Mesh.global_transform.basis = Basis(Quaternion(cam_basis.get_euler() + Vector3(0, 0, deg_to_rad(180))))
		$Mesh.rotation.z += deg_to_rad(180)


func set_active(value : bool) -> void:
	$HUD.visible = value
	super.set_active(value)


func no_ammo() -> void:
	if not $NoAmmo.playing:
		$NoAmmo.play()
