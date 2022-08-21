extends MissileBullet


func check_collisions():
	var long = translation.distance_to(_old_translation)
	var ray := $RayCast
	if ray.is_colliding():
		translation = ray.get_collision_point()
		$HitParticles.hide()
		$Explosion.show()
		$HitAudio.pitch_scale = rand_range(1, 1.7)
		$HitAudio.play()
		$AnimationPlayer.play("hit")
		_hit = true
		$ExplosiveArea.explode()
		return
	ray.cast_to = Vector3(0, 0, -long)
