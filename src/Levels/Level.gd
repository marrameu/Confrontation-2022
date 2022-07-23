extends Spatial


var player_scene : PackedScene = preload("res://src/Troops/Player.tscn")
var middle_point = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var _player = spawn_player()


func _on_player_entered_ship(ship : Spatial):
	$PlayerShipCam.ship = ship
	ship.cam = $PlayerShipCam # no hauria de caldre
	$PlayerShipCam.make_current()
	$PlayerShipCam.init_cam()
	


func spawn_player(pos := Vector3(0, 2, 0)) -> Spatial:
	var new_player = player_scene.instance()
	new_player.translation = pos
	new_player.pilot_man = $PilotManagers/PlayerMan
	add_child(new_player)
	$PlayerTroopCam.cam_pos_path = new_player.get_node("CameraBase/CameraPosition").get_path()
	"""cam en lloc de self"""
	new_player.connect("entered_ship", self, "_on_player_entered_ship")
	$PlayerTroopCam.make_current()
	return new_player
