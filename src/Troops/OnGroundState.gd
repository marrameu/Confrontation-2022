"""
Walk i córrer
"""
extends MoveState
class_name OnGroundState


func handle_input(event : InputEvent):
	if event.is_action_pressed("jump") and has_contact:
		emit_signal("finished", "jump")
	elif event.is_action_pressed("roll"):
		emit_signal("finished", "roll")
