extends MissileBullet


func _hit(body) -> bool:
	$Area.explode()
	return false
