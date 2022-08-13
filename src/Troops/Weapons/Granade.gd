extends RigidBody

export var impulse := 25.0
export var damage := 300.0


#func init(direction):
#	rotation = direction


func _ready():
	mode = RigidBody.MODE_RIGID
	apply_central_impulse(-global_transform.basis.z * impulse)
	$AnimationPlayer.play("explode")


func _on_Area_area_entered(area):
	area.owner.get_node("HealthSystem").take_damage(damage / (area.global_transform.origin.distance_to(translation) / 2))
