extends "res://src/HUD/DamageIndicator.gd"



func _process(delta):
	if not attacker or not weakref(attacker).get_ref():
		return
	
	var t = Transform2D()
	t = t.rotated(-myself.rotation.y)
	t.origin = Vector2(myself.global_transform.origin.x, myself.global_transform.origin.z)
	var direction := Vector2(t.origin.direction_to(Vector2(attacker.global_transform.origin.x, attacker.global_transform.origin.z))).normalized()
	var z_dot = direction.dot(t.basis_xform(Vector2(0, 1)))
	var z_cross = direction.cross(t.basis_xform(Vector2(0, 1)))
	var prova = Vector2(-z_dot, z_cross).normalized()
	var rot : float = Vector2().angle_to_point(prova)
	rotation = rad_to_deg(rot)
