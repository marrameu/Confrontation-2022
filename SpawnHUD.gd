extends CanvasLayer


signal respawn
signal start_battle
signal change_spectate
signal change_cam

export var battle_state_path : NodePath 
onready var battle_state = get_node(battle_state_path)

var current_specting_location : int = 0
var current_location_index : int = 0

var waiting := false

var selected_cp : CommandPost = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if waiting:
		$Control/WaitTime.text = "ESPEREU " + str(int($PlayerRespawnTimer.time_left)) + "\""
	# $Control/StartButton.disabled = !selected_cp


func show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"%CPButtons".update()
	$Control.show()
	$"%ChooseClass".show()
	$"%ChooseCP".hide()
	$"%ClassesButtons".get_child(0).grab_focus()


func _on_ClassButton_pressed():
	# $Control/StartButton.show()
	$"%ChooseClass".hide()
	$"%ChooseCP".show()
	$"%CPButtons".get_child(0).grab_focus()
	# $Control/StartButton.grab_focus()


func _on_StartButton_pressed():
	# if battle_state.battle_started # NO CAL
	if not selected_cp:
		return
	
	emit_signal("start_battle")
	emit_signal("respawn", selected_cp.global_transform.origin + Vector3.UP * 2)
	$Control.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	selected_cp = null


func _on_cp_button_pressed(cp : CommandPost):
	if (cp.m_team == 1 and not PlayerInfo.player_blue_team) or (cp.m_team == 2 and PlayerInfo.player_blue_team):
		selected_cp = cp
	_on_StartButton_pressed()


func enable_spawn(enable : bool):
	if enable:
		$Control/WaitTime.visible = false
		waiting = false
	else:
		waiting = true
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


func _on_ChangeCamButton_pressed():
	emit_signal("change_cam")
	$"%ChangeCamButton".text = "Terra" if $"%ChangeCamButton".text == "Espai" else "Espai"


func _on_ChangeClassButton_pressed():
	show()
