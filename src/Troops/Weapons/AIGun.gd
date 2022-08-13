extends Gun


func _ready() -> void:
	set_active(true)
	$RayCast.global_transform.origin = owner.global_transform.origin


func _process(delta):
	ammo = MAX_AMMO
