extends "AIShipState.gd"


var enemy_cs : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func enter():
	print(owner, " entered ", name)
	
	if owner.blue_team:
		enemy_cs = get_node("/root/Level/BigShips/CapitalShipRed")
		owner.shooting.target = enemy_cs
	else:
		enemy_cs = get_node("/root/Level/BigShips/CapitalShipBlue")
		owner.shooting.target = enemy_cs
	
	owner.shooting.wants_shoots[0] = true
	owner.shooting.wants_shoots[1] = true
	
	var t = Timer.new()
	t.set_wait_time(randf_range(7, 14))
	self.add_child(t)
	t.start()
	t.connect("timeout",Callable(self,"update_point"))
	t.connect("timeout",Callable(t,"queue_free"))


func update_point():
	var count = randi() % (enemy_cs.get_node("ShipPoints").get_child_count() - 1)
	owner.input.target = enemy_cs.get_node("ShipPoints").get_child(count).global_transform.origin
