extends "res://src/Ships/ShipShooting.gd"


onready var ray : RayCast = $RayCast

var target : Spatial

var enemy_in_range := false


func _init():
	lock_missile_timer = $LockMissileTimer


func _physics_process(delta):
	pass
	#if $RayCast.is_colliding():
	#	enemy_in_range = $RayCast.get_collider() == target


func _process(delta):
	enemy_in_range = false
	# cal la weakref? si pot ser evitat millor
	# si ho faig amb body_entered/exited el problema esq si canvia d'enemic i l'anterior no ha sortit de l'àrea...
	if weakref(target).get_ref():
		var direction := Vector3(target.translation - owner.translation).normalized()
		var x = direction.dot(owner.global_transform.basis.x)
		var y = direction.dot(owner.global_transform.basis.y)
		var prova = Vector2(-x, -y).length()
		if prova < 0.2:
			enemy_in_range = true
	
		if wants_shoots[1] and ammos[1]: # for cada wantsshoot comprovar si és míssil
			if not target_locked:
				if not locking_target_to_missile:
					lock_target = target
					lock_target_to_missile() # SI POT, SI NO Q DISPARI
				return
			else:
				if can_shoots[1]:
					shoot_bullet(1, target.translation)
				return
		
		#if not ammos[0]
		ammos[0] = MAX_AMMOS[0] # temporal
		
		if enemy_in_range:
			for value in wants_shoots:
				if wants_shoots[value] and can_shoots[value]:
					if get_tree().has_network_peer():
						rpc("shoot", target.translation)
					else:
						shoot_bullet(value, target.translation)


func _on_ShootingArea_body_entered(body):
	return
	if body == target:
		enemy_in_range = true


func _on_ShootingArea_body_exited(body):
	return
	if body == target:
		enemy_in_range = false
