extends Bullet

signal headshot

@onready var headshot_damage : int = damage * 2

func _ready():
	if shooter.has_method("_on_headshot"):
		connect("headshot",Callable(shooter,"_on_headshot"))


func _on_hit(body):
	var headshot := false
	if body.is_in_group("Troops"):
		if $RayCast3D.get_collision_point().y > body.get_global_transform().origin.y + 2.95:
			damage = headshot_damage
			headshot = true
	if super._on_hit(body):
		if headshot:
			emit_signal("headshot")

