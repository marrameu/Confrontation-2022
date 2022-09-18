extends CanvasLayer


const player_leaderboard_scene : PackedScene = preload("res://src/HUD/PlayerLeaderboard.tscn")


func init():
	for pilot_man in get_tree().current_scene.get_node("PilotManagers").get_children():
		var new_leaderboard = player_leaderboard_scene.instantiate()
		new_leaderboard.pilot_man = pilot_man
		if pilot_man.blue_team:
			$Control/Teams/Blue.add_child(new_leaderboard)
		else:
			$Control/Teams/Red.add_child(new_leaderboard)


func _process(_delta):
	var last_visible = visible
	visible = Input.is_action_pressed("leaderboard")
	if visible and !last_visible:
		_sort_team($Control/Teams/Blue)
		_sort_team($Control/Teams/Red)


func _sort_team(container) -> void:
	var num_children = container.get_child_count()
	for ii in range(1, num_children):
		for i in range(1, num_children):
			if i+1 < num_children:
				if float(container.get_child(i).get_node("Points").text) < float(container.get_child(i+1).get_node("Points").text):
					container.move_child(container.get_child(i+1),i)
