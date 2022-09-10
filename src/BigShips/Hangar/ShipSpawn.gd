extends Position3D
class_name ShipSpawn

export var ship_scene : PackedScene = preload("res://NewShip.tscn")
export var blue_team := false

var spawn_ships := false
export var simultaneous_ships : int = 2
var last_ship : Ship
var current_number_of_ships_instanced := 0


func _ready():
	pass # instance_ship()
	# pq no va?


func _physics_process(delta):
	if spawn_ships:
		$Label3D.text = str(current_number_of_ships_instanced)
		if current_number_of_ships_instanced < simultaneous_ships:
			if $Timer.is_stopped():
				if weakref(last_ship).get_ref():
					if last_ship.translation.distance_to(global_transform.origin) > 10:
						$Timer.start()
				else:
					$Timer.start()
	else:
		$Timer.stop()
		$Label3D.text = "X"


func instance_ship():
	var new_ship = ship_scene.instance()
	new_ship.translation = global_transform.origin
	new_ship.blue_team = blue_team
	new_ship.connect("ship_died", self, "_on_ship_died")
	# rotació tmb
	get_tree().current_scene.add_child(new_ship)
	last_ship = new_ship
	current_number_of_ships_instanced += 1


func _on_ship_died():
	current_number_of_ships_instanced -= 1


func change_team(m_team : int):
	if m_team == 0:
		spawn_ships = false
		if weakref(last_ship).get_ref():
			if last_ship.is_player_or_ai == 0:
				last_ship.get_node("HealthSystem").take_damage(1000000, true)
	else:
		spawn_ships = true
		blue_team = m_team == 2
