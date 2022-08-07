extends CommandPost


# Called when the node enters the scene tree for the first time.
func _ready():
	start_team = 1 if not owner.blue_team else 2
	._ready()
