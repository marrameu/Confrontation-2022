extends "ChooseObjective.gd"


# temporal
func enter():
	emit_signal("finished", "enter_cs")


func _on_enemy_cs_wo_shields(cs):
	emit_signal("finished", "enter_cs")
