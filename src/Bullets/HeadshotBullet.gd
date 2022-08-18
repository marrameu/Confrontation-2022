extends Bullet

signal headshot

onready var headshot_damage : int = damage * 2

func _ready():
	if shooter.has_method("_on_headshot"):
		connect("headshot", shooter, "_on_headshot")


func _hit(body):
	var headshot := false
	if body.is_in_group("Troops"):
		if $RayCast.get_collision_point().y > body.get_global_transform().origin.y + 1.2:
			damage = headshot_damage
			headshot = true
	if ._hit(body):
		if headshot:
			emit_signal("headshot")

