extends TabContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_input(event):
	if owner.visible:
		if event.is_action_pressed("left_tab"):
			self.current_tab = current_tab-1
		
		elif event.is_action_pressed("right_tab"):
			self.current_tab = current_tab+1
	else:
		current_tab = 0


