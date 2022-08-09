extends "res://Turret.gd"

onready var ray : RayCast = $Spatial/RayCast


func _process(delta):
	# raycast
	if enemies:
		wants_shoot = true
		if ray.is_colliding():
			for enemy in enemies:
				if ray.get_collider() == enemy:
					pass


func _on_Area_area_entered(body):
	if body.owner.is_in_group("Ships"):
		if not body.owner.pilot_man:
			return
		if body.owner.pilot_man.blue_team != owner.blue_team:
			enemies.push_back(body.owner)
	elif body.owner.is_in_group("BigShips"):
		if body.owner.blue_team != owner.blue_team:
			enemies.push_back(body.owner)
			# print(name + " a matar " + body.name)


func _on_Area_area_exited(body):
	var a := 0
	for enemy in enemies:
		if enemy == body.owner:
			enemies.remove(a)
			break
		a += 1
