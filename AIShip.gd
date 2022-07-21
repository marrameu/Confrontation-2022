extends Ship

signal big_ship_shields_down

var battle_man


# Called when the node enters the scene tree for the first time.
func _ready():
	$StateMachine.set_active(true)


func _on_BigShip_shields_down(ship):
	emit_signal("big_ship_shields_down", ship)
