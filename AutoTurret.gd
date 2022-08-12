extends "res://Turret.gd"

onready var ray : RayCast = $Spatial/RayCast


func _process(delta):
	# raycast
	wants_shoot = false
	if enemies:
		if ray.is_colliding():
			for enemy in enemies:
				if ray.get_collider() == enemy:
					wants_shoot = true


func _on_Area_body_entered(body):
	if body.is_in_group("Ships"):
		if not body.pilot_man:
			return
		if body.pilot_man.blue_team != owner.blue_team:
			enemies.push_back(body)
	elif body.is_in_group("BigShips"):
		if body.blue_team != owner.blue_team:
			enemies.push_back(body)
			# print(name + " a matar " + body.name)


func _on_Area_body_exited(body):
	var a := 0
	for enemy in enemies:
		if enemy == body:
			enemies.remove(a)
			break
		a += 1


func set_bullets_shooter(bullet : Bullet):
	bullet.init(owner, owner.blue_team)
	bullet.add_exception($HurtBox)
