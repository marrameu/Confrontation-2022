extends Spatial

var current_weapon_ind : int = 0

# export var abilities : Dictionary


func _ready():
	for weapon in $Weapons.get_children():
		weapon.set_active(false)
	$Weapons.get_child(current_weapon_ind).set_active(true)


func _process(delta):
	if Input.is_action_just_released("change_weapon"):
		$Weapons.get_child(current_weapon_ind).set_active(false)
		current_weapon_ind += 1
		if current_weapon_ind > $Weapons.get_child_count() - 1:
			current_weapon_ind = 0
		$Weapons.get_child(current_weapon_ind).set_active(true)
