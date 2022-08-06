extends CanvasLayer


signal respawn
signal start_battle
signal change_spectate

export var battle_state_path : NodePath 
onready var battle_state = get_node(battle_state_path)

var current_specting_location : int = 0
var current_location_index : int = 0

var waiting := false


# Called when the node enters the scene tree for the first time.
func _ready():
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if waiting:
		$Control/WaitTime.text = "ESPEREU " + str(int($PlayerRespawnTimer.time_left)) + "\""


func show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Control.show()
	$Control/StartButton.hide()
	$Control/HBoxContainer.show()
	
	$Control/HBoxContainer/Button.grab_focus()


func _on_Button_pressed():
	$Control/StartButton.show()
	$Control/HBoxContainer.hide()
	$Control/StartButton.grab_focus()


func _on_StartButton_pressed():
	# if battle_state.battle_started # NO CAL
	emit_signal("start_battle")
	emit_signal("respawn")
	$Control.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func enable_spawn(enable : bool):
	if enable:
		$Control/StartButton.disabled = false
		$Control/WaitTime.visible = false
		waiting = false
	else:
		waiting = true
		$Control/StartButton.disabled = true
		$PlayerRespawnTimer.start()
		$Control/WaitTime.visible = true


func _on_spectate_pressed(ship_type : int, new_index : int = 0):
	var current_buttons = $Control/Spectate.get_child(current_specting_location) # haruia de ser -1, però com q hi ha un label +1
	if new_index == 0: # ha clicat al botó del mig
		if not current_specting_location == 0: # no tenia res seleccionat
			current_buttons.get_node("Left").hide()
			current_buttons.get_node("Right").hide()
			current_location_index = 0
		if ship_type == current_specting_location: # ha clciat al tipus ja seleccionat
			current_specting_location = 0
			emit_signal("change_spectate", current_specting_location)
			return
	
	current_specting_location = ship_type
	var new_buttons = $Control/Spectate.get_child(current_specting_location) # haruia de ser -1, però com q hi ha un label +1
	new_buttons.get_node("Left").show()
	new_buttons.get_node("Right").show()
	current_location_index += new_index
	emit_signal("change_spectate", current_specting_location, current_location_index)
