extends Spatial

var enemies := []

func _ready() -> void:
	pass

func _process(_delta):
	pass


# no sé quina hauria de ser la closest_dir per defecte
func update_enemy(closest_dir := -0.5, closes_dist := 1000.0) -> Spatial:
	var most_frontal_enenmy : Spatial = null
	
	var enemies := []
	for troop in get_tree().get_nodes_in_group("Troops"):
		if troop.blue_team != owner.blue_team:
			var dist : float = troop.translation.distance_to(owner.translation)
			if dist < closes_dist:
				var direction := Vector3(troop.global_transform.origin - owner.translation).normalized()
				var a = direction.dot(owner.global_transform.basis.z)
				
				if a > closest_dir:
					var health_system : HealthSystem = troop.get_node("HealthSystem")
					if health_system.health > 0:
						var ray := get_world().direct_space_state.intersect_ray(owner.translation, troop.translation, [owner, troop], 3) # sols environmmmment
						if not ray:
							closest_dir = a
							closes_dist = dist
							most_frontal_enenmy = troop
	
	return most_frontal_enenmy


func _on_Timer_timeout():
	if not owner.current_enemy: # timer pq no ho hagi de calcular cada frame
		owner.current_enemy = update_enemy()


func _on_HealthSystem_damage_taken(attacker : Spatial):
	if owner.current_enemy != attacker:
		if weakref(attacker).get_ref():
			owner.look_at(attacker.translation, Vector3.UP)
			owner.rotation = Vector3(0, rotation.y + deg2rad(180), 0)
			owner.orthonormalize()
			owner.current_enemy = update_enemy()
