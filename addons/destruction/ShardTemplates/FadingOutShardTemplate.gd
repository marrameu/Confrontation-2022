extends RigidBody3D

func _ready():
	var material : StandardMaterial3D = $MeshInstance3D.mesh.surface_get_material(0)
	if not material:
		return
	material = material.duplicate()
	$MeshInstance3D.material_override = material
	material.flags_transparent = true
	
	$Tween.interpolate_property(material, "albedo_color", Color.WHITE, Color(1, 1, 1, 0), 2, Tween.TRANS_EXPO, Tween.EASE_OUT, 4)
	$Tween.start()
