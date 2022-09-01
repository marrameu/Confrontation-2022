extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$DistanceRayCast.collision_mask = collision_mask



func _on_Area_area_entered(area):
	print("expllosionara ", area)
	$EnvironmentRayCast.cast_to = to_local(area.owner.global_translation)
	$EnvironmentRayCast.force_raycast_update()
	if $EnvironmentRayCast.is_colliding():
		return # PARET
	
	$DistanceRayCast.cast_to = to_local(area.owner.global_translation)
	$DistanceRayCast.force_raycast_update()
	if $DistanceRayCast.is_colliding():
		area.owner.get_node("HealthSystem").take_damage(owner.damage / ($DistanceRayCast.get_collision_point().distance_to(translation) / 2) * 100)
		# emit_signal("damagable_hit")
	else:
		print("MALAMENT RAYO")


func explode() -> void:
	$CollisionShape.disabled = false
