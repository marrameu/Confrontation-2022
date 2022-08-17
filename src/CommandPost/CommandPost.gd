extends Spatial

class_name CommandPost

signal add_points

export var capturable := true
export(int, 0, 2) var start_team := 0

const materials := {
	0: preload("res://assets/materials/command_post/grey.tres"),
	1: preload("res://assets/materials/command_post/blue.tres"),
	2: preload("res://assets/materials/command_post/red.tres"),
	3: preload("res://assets/materials/command_post/yellow.tres")
}
var team_count := [0.0, 0.0, 0.0]
var m_team : int = 0
var bodies : PoolIntArray = [0, 0, 0]

var old_menus := []
var buttons := []

puppet var slave_team_count := [0.0, 0.0, 0.0]

var is_ground : bool = false


func _ready() -> void:
	$TextureProgress.hide()
	
	#PQ 3 EQUIPS?
	for value in team_count:
		value = 0
	if start_team != 0:
		team_count[start_team - 1] = 10


func _process(delta : float) -> void:
	"""
	update_menus()
	
	for i in range(0, old_menus.size()):
		var scene_camera : Camera = get_node("/root/Main").players_cameras[old_menus[i].get_parent().number_of_player - 1].scene_camera
		
		if old_menus[i].get_node("SpawnMenu").visible and not scene_camera.is_position_behind(global_transform.origin):
			buttons[i].rect_position = scene_camera.unproject_position(global_transform.origin)
			# Mirar si es pot treure
			buttons[i].rect_position -= Vector2(buttons[i].rect_size.x / 2, buttons[i].rect_size.y / 2)
			
			update_button_color(buttons[i])
			buttons[i].show()
		else:
			buttons[i].hide()
	"""
	
	if not capturable:
		return
	
	bodies[0] = 0
	bodies[1] = 0
	bodies[2] = 0
	var texture_progress_visible := false
	for body in $Area.get_overlapping_bodies():
		if body.is_in_group("Troops"):
			if not body.dead:
				if body.is_in_group("Players"):
					texture_progress_visible = true
				var body_team : int = 1 if not body.blue_team else 2
				match body_team:
					1:
						bodies[0] += 1 # vermell
					2:
						bodies[1] += 1 # blau
					3:
						bodies[2] += 1
	$TextureProgress.visible = texture_progress_visible
	$Label.visible = texture_progress_visible and ((m_team == 2 and PlayerInfo.player_blue_team) or (m_team == 1 and not PlayerInfo.player_blue_team))


func _physics_process(delta : float) -> void:
	if team_count[0] > 7:
		m_team = 1 # vermell
		if $Timer.is_stopped():
			$Timer.start()
	elif team_count[1] > 7:
		m_team = 2 # blau
		if $Timer.is_stopped():
			$Timer.start()
	elif team_count[2] > 7:
		m_team = 3
	elif team_count[0] + team_count[1] + team_count[2] < 7:
		if not $Timer.is_stopped():
			$Timer.stop()
		m_team = 0
	
	update_material()
	
	if not capturable: # TOT AIXÒ S'HA DE REFER URGENTMENT
		return
	
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			rset_unreliable("slave_team_count", team_count)
		else:
			team_count = slave_team_count
			return
	
	# Sphagetti Code
	if bodies[0] > 0 and bodies[1] + bodies[2] == 0:
		# Team 1 Conquering
		if team_count[1] + team_count[2] > 0:
			team_count[1] = clamp(team_count[1] - delta * bodies[0], 0, 10)
			team_count[2] = clamp(team_count[2] - delta * bodies[0], 0, 10)
		else:
			team_count[0] = clamp(team_count[0] + delta * bodies[0], 0, 10)
		
	elif bodies[1] > 0 and bodies[0] + bodies[2] == 0:
		# Team 2 Conquering
		if team_count[0] + team_count[2] > 0:
			team_count[0] = clamp(team_count[0] - delta * bodies[1], 0, 10)
			team_count[2] = clamp(team_count[2] - delta * bodies[1], 0, 10)
		else:
			team_count[1] = clamp(team_count[1] + delta * bodies[1], 0, 10)
		
	elif bodies[2] > 0 and bodies[0] + bodies[1] == 0:
		# Team 3 Conquering
		if team_count[0] + team_count[1] > 0:
			team_count[0] = clamp(team_count[0] - delta * bodies[2], 0, 10)
			team_count[1] = clamp(team_count[1] - delta * bodies[2], 0, 10)
		else:
			team_count[2] = clamp(team_count[2] + delta * bodies[2], 0, 10)
	
	var max_value = 0
	for value in team_count:
		if value > max_value:
			max_value = value
			if value == team_count[0]:
				$TextureProgress.tint_progress = Color.red
			elif value == team_count[1]:
				$TextureProgress.tint_progress = Color.blue
	$TextureProgress.value = max_value


func update_button_color(button : Button) -> void:
	if m_team == 0:
		button.add_color_override("font_color", Color.white)
	elif m_team == get_node("/root/Main").local_players[0].get_node("TroopManager").m_team:
		button.add_color_override("font_color", Color("b4c7dc"))
	else:
		button.add_color_override("font_color", Color("dcb4b4"))


func update_menus() -> void:
	var new_menus := []
	
	for child in get_node("/root/Main/SelectionMenus").get_children():
		for menu in child.get_children():
			new_menus.push_back(menu)
	
	var menus_to_remove := []
	
	for i in range(0, new_menus.size()):
		for old_menu in old_menus:
			if new_menus[i] == old_menu:
				menus_to_remove.push_back(i)
	
	var elements_removed := 0
	for i in range(0, menus_to_remove.size()):
		new_menus.remove(menus_to_remove[i - elements_removed])
		elements_removed += 1
	
	for new_menu in new_menus:
		old_menus.push_back(new_menu)
		
		var button : Button = load("res://src/CommandPost/CPButton.tscn").instance()
		new_menu.get_node("SpawnMenu/Buttons").add_child(button)
		button.connect("pressed", new_menu.get_parent(), "_on_CommandPostButton_pressed", [self])
		connect("tree_exiting", button, "queue_free")
		buttons.push_back(button)


func update_material() -> void:
	if m_team == 0:
		$MeshInstance.set_material_override(materials[0])
	elif m_team == 3:
		$MeshInstance.set_material_override(materials[3])
	elif m_team == 2:
		$MeshInstance.set_material_override(materials[1])
	elif m_team == 1:
		$MeshInstance.set_material_override(materials[2])


func _on_Timer_timeout():
	var blue_team = m_team == 2
	emit_signal("add_points", blue_team)
