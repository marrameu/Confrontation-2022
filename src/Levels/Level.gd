extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$PlayerTroopCam.make_current()
	
	"""cam en lloc de self"""
	$Player.connect("entered_ship", self, "_on_player_entered_ship")


func _on_player_entered_ship(ship : Spatial):
	$PlayerShipCam.ship = ship
	ship.cam = $PlayerShipCam # no hauria de caldre
	$PlayerShipCam.make_current()
	$PlayerShipCam.init_cam()
	
