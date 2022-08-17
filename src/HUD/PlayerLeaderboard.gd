extends HBoxContainer


var pilot_man : PilotManager


func _ready():
	$Name.text = pilot_man.nickname


func _process(delta):
	$Points.text = str(pilot_man.points)
