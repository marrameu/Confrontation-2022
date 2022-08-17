extends "ChooseObjective.gd"


func _on_enemy_cs_wo_shields(cs):
	emit_signal("finished", "enter_cs")
