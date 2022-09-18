extends "res://src/HUD/DamageIndicator.gd"


func _process(delta):
	if not attacker or not weakref(attacker).get_ref():
		return
	
	var direction := Vector3(attacker.position - myself.position).normalized()
	var x = direction.dot(myself.global_transform.basis.x)
	var y = direction.dot(myself.global_transform.basis.y)
	var prova = Vector2(-y, x).normalized()
	var rot : float = rad_to_deg(Vector2().angle_to_point(prova))
	rotation = rot
