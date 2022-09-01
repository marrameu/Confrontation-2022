extends "res://src/Troops/TroopShooting.gd"


func _process(delta):
	if Input.is_action_just_released("change_weapon") and owner.can_change_weapon:
		change_weapon()
