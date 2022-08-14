"""
Walk i córrer
"""
extends MoveState
class_name OnGroundState


func handle_input(event : InputEvent):
	if not has_contact:
		return
	if event.is_action_pressed("jump"):
		emit_signal("finished", "jump")
	elif event.is_action_pressed("roll"):
		emit_signal("finished", "roll")
	elif event.is_action_pressed("melee"):
		emit_signal("finished", "melee")
