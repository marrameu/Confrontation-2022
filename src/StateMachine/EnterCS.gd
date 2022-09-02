extends "AIShipState.gd"

var path : Node
var ind : int = 0

func enter():
	for cs in get_tree().get_nodes_in_group("CapitalShips"):
		if cs.blue_team != owner.blue_team:
			path = cs.get_node("EnterPath")
			owner.input.target = path.get_child(0).global_translation
	owner.input.des_throttle = 1.0


func update(delta):
	if owner.translation.distance_to(owner.input.target) < 30:
		owner.input.ignore_collisions = true
		owner.input.des_throttle = 0.7 # 0.4 abans
		ind += 1
		if path.get_child(ind):
			owner.input.target = path.get_child(ind).global_translation
		else:
			owner.land()
