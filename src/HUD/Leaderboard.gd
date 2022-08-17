extends CanvasLayer


const player_leaderboard_scene : PackedScene = preload("res://src/HUD/PlayerLeaderboard.tscn")


func init():
	for pilot_man in get_tree().current_scene.get_node("PilotManagers").get_children():
		var new_leaderboard = player_leaderboard_scene.instance()
		new_leaderboard.pilot_man = pilot_man
		if pilot_man.blue_team:
			$Control/Teams/Blue.add_child(new_leaderboard)
		else:
			$Control/Teams/Red.add_child(new_leaderboard)


func _process(_delta):
	visible = Input.is_action_pressed("leaderboard")
	
