extends VBoxContainer


func on_points_added(new_points : int):
	$HBoxContainer2/Label2.text = str(int($HBoxContainer2/Label2.text) + new_points)
	if not $AnimationPlayer.is_playing():
		$"%TotalPointsNumberLabel".text = str(owner.owner.pilot_man.points)
	$AnimationPlayer.play("points_added")