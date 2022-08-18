extends "res://src/Levels/Level.gd"


const ship_scene : PackedScene = preload("res://NewShip.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn_player(pos := Vector3()):
	var new_ship : Ship = ship_scene.instance()
	add_child(new_ship)
	new_ship.translation = Vector3(0, 2000, 0)
	new_ship.init($PilotManagers/PlayerMan)
	new_ship.leave()
	_on_player_entered_ship(new_ship)


func start_battle():
	spawn_player()