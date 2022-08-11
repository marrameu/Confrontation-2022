extends Bullet

signal headshot

export var headshot_damage : int = damage * 2

func _ready():
	connect("headshot", shooter, "_on_headshot")


func _hit(body):
	if body.is_in_group("Troops"):
		if $RayCast.get_collision_point().y > body.get_global_transform().origin.y + 1.2:
			damage = headshot_damage
			emit_signal("headshot")
	._hit(body)

