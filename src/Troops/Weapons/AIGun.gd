extends Gun


func _ready() -> void:
	offset = offset # / 2 # sempre està apuntatn, depèn de la difcultat?
	# damage /= 2
	set_active(true)
	$RayCast.global_transform.origin = owner.global_transform.origin


func _physics_process(_delta):
	ammo = MAX_AMMO
	if shooting:
		if weakref(owner.current_enemy).get_ref():
			look_at(owner.current_enemy.get_node("CollisionShape").global_translation, Vector3(0, 1, 0))
			#rotation.x = -rotation.x
			#rotation.z = -rotation.z
			transform = transform.orthonormalized()
