extends Position3D

const ship_scene : PackedScene = preload("res://NewShip.tscn")

export var simultaneous_ships : int = 2
var last_ship : Ship
var current_number_of_ships_instanced := 0


func _ready():
	pass # instance_ship()
	# pq no va?


func _physics_process(delta):
	$Label3D.text = str(current_number_of_ships_instanced)
	if current_number_of_ships_instanced < simultaneous_ships:
		if $Timer.is_stopped():
			if weakref(last_ship).get_ref():
				if last_ship.translation.distance_to(global_transform.origin) > 10:
					$Timer.start()
			else:
				$Timer.start()


func instance_ship():
	var new_ship = ship_scene.instance()
	new_ship.translation = global_transform.origin
	new_ship.connect("ship_died", self, "_on_ship_died")
	# rotació tmb
	get_tree().current_scene.add_child(new_ship)
	last_ship = new_ship
	current_number_of_ships_instanced += 1


func _on_ship_died():
	current_number_of_ships_instanced -= 1
