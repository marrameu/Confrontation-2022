extends Spatial

var current_weapon_ind : int = 0

# export var abilities : Dictionary


func _ready():
	for weapon in owner.get_node("%Weapons").get_children():
		weapon.set_active(false)
	owner.get_node("%Weapons").get_child(current_weapon_ind).set_active(true)


func _process(delta):
	if Input.is_action_just_released("change_weapon") and owner.can_change_weapon:
		owner.get_node("%Weapons").get_child(current_weapon_ind).set_active(false)
		current_weapon_ind += 1
		if current_weapon_ind > owner.get_node("%Weapons").get_child_count() - 1:
			current_weapon_ind = 0
		owner.get_node("%Weapons").get_child(current_weapon_ind).set_active(true)


func reload_current_weapon() -> void:
	owner.get_node("%Weapons").get_child(current_weapon_ind).reload_ammo()


func can_reload() -> bool:
	var current_weapon = owner.get_node("%Weapons").get_child(current_weapon_ind)
	var can := false
	can = !current_weapon.reload_per_sec and current_weapon.ammo != current_weapon.MAX_AMMO
	if can:
		if current_weapon.reload_ammo:
			pass
		else:
			$NoAmmo.play()
			can = false
	return can
