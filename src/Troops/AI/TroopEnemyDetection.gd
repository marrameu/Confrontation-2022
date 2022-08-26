extends Spatial

var enemies := []

func _ready() -> void:
	pass

func _process(_delta):
	pass
	
	"""
	No funciona pq enemies sempre es buida
	
	if get_parent().current_enemy and weakref(get_parent().current_enemy).get_ref():
		if get_parent().current_enemy.translation.distance_to(get_parent().translation) > 500: # si és prou a prop, no és estùpid, sap on s'amaga
			var ray := get_world().direct_space_state.intersect_ray(owner.translation, get_parent().current_enemy.translation, [], 1) # sols environmmmment
			if ray:
				get_parent().current_enemy = null
	"""

func update_enemy(closest_dir := -INF, closes_dist := 1500.0) -> Spatial:
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
						var ray := get_world().direct_space_state.intersect_ray(owner.translation, troop.translation, [], 1) # sols environmmmment
						if not ray:
							closest_dir = a
							closes_dist = dist
							most_frontal_enenmy = troop
	
	return most_frontal_enenmy


func _on_Timer_timeout():
	if not owner.current_enemy: # timer pq no ho hagi de calcular cada frame
		owner.current_enemy = update_enemy()
