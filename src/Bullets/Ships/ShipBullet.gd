extends Spatial
class_name ShipBullet

signal damagable_hit

export var damage := 100
export var bullet_velocity := 700.0

var direction : Vector3
var ship # : Ship

var _hit := false
export var _time_alive := 3.5 #7.0
var _old_translation : Vector3


func _process(delta : float) -> void: # rumiar si fer-ho al physics_process
	if _hit: # Per l'animació d'explosió
		return
	
	move(delta)
	check_collisions()
	
	_time_alive -= delta
	if _time_alive < 0:
		queue_free()
	# fer que depenent de la velocitat q ha recorregut la area canvia de llargada? :/
	
	_old_translation = translation


func move(delta):
	translation += delta * direction * bullet_velocity


func check_collisions():
	var long = translation.distance_to(_old_translation)
	for ray in $RayCasts.get_children():
		if ray.is_colliding():
			var body = ray.get_collider().owner
			if body != ship:
				if body.is_in_group("Damagable"):
					emit_signal("damagable_hit") # s'ha de fer abans, si no es menja l'animació "killed"
					if not body.get_node("HealthSystem").is_connected("die", ship, "_on_enemy_died"):
						body.get_node("HealthSystem").connect("die", ship, "_on_enemy_died")
					if get_tree().has_network_peer():
						if get_tree().is_network_server():
							body.get_node("HealthSystem").rpc("take_damage", damage, false, ship)
					else:
						body.get_node("HealthSystem").take_damage(damage, false, ship)
				
				translation = ray.get_collision_point()
				$HitParticles.hide()
				$Explosion.show()
				# $AudioStreamPlayer3D2.play()
				$AnimationPlayer.play("explode")
				_hit = true
		ray.cast_to = Vector3(0, 0, -long)


func _on_VisibilityNotifier_screen_entered():
	pass
	#visible = true


func _on_VisibilityNotifier_screen_exited():
	pass
	#visible = false
