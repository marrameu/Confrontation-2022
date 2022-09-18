extends Area

signal damagable_hit


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("damagable_hit", owner.shooter, "_on_damagable_hit")
	$DistanceRayCast.collision_mask = collision_mask



func _on_Area_area_entered(area):
	print("expllosionara ", area)
	
	$DistanceRayCast.cast_to = to_local(area.global_translation)
	$DistanceRayCast.force_raycast_update()
	if $DistanceRayCast.is_colliding():
		if not weakref(owner.shooter).get_ref():
			return
		
		# PARET
		$EnvironmentRayCast.cast_to = $DistanceRayCast.get_collision_point()
		$EnvironmentRayCast.force_raycast_update()
		if $EnvironmentRayCast.is_colliding():
			return
		
		# q resti punts si és del mateix equip
		if area.owner.blue_team != owner.shooter.blue_team:
			emit_signal("damagable_hit")
			if owner.shooter.has_method("_on_enemy_died"):
				if not area.owner.get_node("HealthSystem").is_connected("die", owner.shooter, "_on_enemy_died"):
					area.owner.get_node("HealthSystem").connect("die", owner.shooter, "_on_enemy_died")
		area.owner.get_node("HealthSystem").take_damage(owner.damage / ($DistanceRayCast.get_collision_point().distance_to(global_translation) / 5), false, owner.shooter)
		print($DistanceRayCast.get_collision_point().distance_to(global_translation))
	else:
		print("MALAMENT RAYO")


func explode() -> void:
	$CollisionShape.disabled = false
