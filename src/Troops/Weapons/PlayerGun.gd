extends Gun

var init_offset : Vector2

export var continuous := true

onready var cam_base := get_tree().current_scene.get_node("%CameraBase")

onready var original_rot : Vector3 = $Mesh.rotation


func _ready():
	$"%Reload".visible = !reload_per_sec
	init_offset = offset
	connect("shoot", get_tree().current_scene.get_node("CameraBase"), "shake_camera", [self])


func _process(delta):
	if not active:
		#$HUD/Crosshair/AnimationPlayer.current_animation = "RESET"
		return
	
	$HUD.get_node("%Crosshair/AnimationTree").set("parameters/conditions/!zooming", !cam_base.zooming)
	$HUD.get_node("%Crosshair/AnimationTree").set("parameters/conditions/zooming", cam_base.zooming)
	
	$"%Ammo".value = ammo/MAX_AMMO*100
	if !reload_per_sec:
		$"%Reload".value = reload_ammo/MAX_RELOAD_AMMO*100
	
	offset = init_offset/2 if get_tree().current_scene.get_node("CameraBase").zooming else init_offset
	
	if not continuous:
		shooting = owner.can_shoot and Input.is_action_just_pressed("shoot")
	else:
		shooting = owner.can_shoot and Input.is_action_pressed("shoot")
	
	var cam := get_viewport().get_camera()
	var cam_basis : Basis = cam.global_transform.basis
	
	$RayCast.global_transform.origin = cam.global_transform.origin #- cam.global_transform.basis.z * 5 # distància fins al jugador
	$RayCast.global_transform.basis = Basis(cam_basis.get_euler())


func _physics_process(delta):
	$HUD.get_node("%Crosshair").modulate = Color("ffffff") if owner.can_shoot else Color("3fffffff")
	if not owner.can_shoot: #or not get_viewport().get_camera().owner.zooming:
		$Mesh.rotation = original_rot
		return
	
	$RayCast.force_raycast_update()
	if $RayCast.is_colliding():
		$Mesh.look_at($RayCast.get_collision_point(), Vector3.UP)
		# $Mesh.rotate($Mesh.transform.basis.y, 180)
		"""var new_mesh = MeshInstance.new()
		new_mesh.mesh = CubeMesh.new()
		get_tree().current_scene.add_child(new_mesh)
		new_mesh.translation = $RayCast.get_collision_point()"""
	else:
		var cam := get_viewport().get_camera()
		var cam_basis : Basis = cam.global_transform.basis
		$Mesh.global_transform.basis = Basis(cam_basis.get_euler() + Vector3(0, 0, deg2rad(180)))
		$Mesh.rotation_degrees.z += 180


func set_active(value : bool) -> void:
	$HUD.visible = value
	.set_active(value)


func no_ammo() -> void:
	if not $NoAmmo.playing:
		$NoAmmo.play()
