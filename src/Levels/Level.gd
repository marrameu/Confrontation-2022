extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$PlayerTroopCam.make_current()
	# $PlayerShipCam.ship = $PlayerShip
	# ship.pilot_man = $PilotManager
	# ship.cam = $Camera
	
	# $Camera.make_current()
	# $Camera.init_cam()
