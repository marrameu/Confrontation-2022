extends "AIShipState.gd"


var target_ship : Node3D


func update(_delta):
	if not target_ship or not weakref(target_ship).get_ref():
		emit_signal("finished", "choose_objective")
		return
	
	if target_ship.get_node("HealthSystem").shield:
		emit_signal("finished", "choose_objective")
		return
	
	owner.input.target = target_ship.position
	owner.input.des_throttle = 1.0 # turbo tmb
	if owner.position.distance_to(target_ship.position) < 1000:
		var closest_enemy = closest_enemy()
		if closest_enemy:
			owner.shooting.target = closest_enemy
			emit_signal("finished", "attack_enemy")
