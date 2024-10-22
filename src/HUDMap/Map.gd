extends CanvasLayer


const ship_min_scene : PackedScene = preload("res://src/HUDMap/NormalShipMin.tscn")
const attack_ship_min_scene : PackedScene = preload("res://src/HUDMap/AttackShipMin.tscn")
const cs_min_scene : PackedScene = preload("res://src/HUDMap/CSMin.tscn")
const support_ship_min_scene : PackedScene = preload("res://src/HUDMap/SupportShipMin.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Control.visible = Input.is_action_pressed("map")


func add_normal_ship(ship : Node3D, is_player := false):
	var new_ship_min : Control
	if ship.is_in_group("Ships"):
		new_ship_min = ship_min_scene.instantiate()
		new_ship_min.modulate = Color.cornflower if ship.blue_team else Color.INDIAN_RED
	elif ship.is_in_group("BigShips"):
		if ship.is_in_group("AttackShips"):
			new_ship_min = attack_ship_min_scene.instantiate()
		elif ship.is_in_group("SupportShips"):
			new_ship_min = support_ship_min_scene.instantiate()
		elif ship.is_in_group("CapitalShips"):
			new_ship_min = cs_min_scene.instantiate()
		new_ship_min.modulate = Color.cornflower if ship.blue_team else Color.INDIAN_RED
	if not new_ship_min:
		return # SpaceStation
	$Control.add_child(new_ship_min)
	new_ship_min.true_self = ship
	# new_ship_min.position = Vector2(randf_range(0, 1000), randf_range(0, 1000))
