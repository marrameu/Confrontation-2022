extends Control

var attacker : Spatial

func _process(delta):
	for ship in get_tree().get_nodes_in_group("CapitalShips"):
		if ship.blue_team:
			attacker = ship
	
	if not attacker or not weakref(attacker).get_ref():
		return
	
	var my_ship = get_parent().owner.owner
	var direction := Vector3(attacker.translation - my_ship.translation).normalized()
	var x = direction.dot(my_ship.global_transform.basis.x)
	var y = direction.dot(my_ship.global_transform.basis.y)
	var prova = Vector2(-y, x).normalized()
	var rot : float = rad2deg(Vector2().angle_to_point(prova))
	rect_rotation = rot


func _on_Timer_timeout():
	queue_free()


func restart_timer():
	$Timer.start()
