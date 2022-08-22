"""
Walk i córrer
"""
extends MoveState
class_name OnGroundState

var direction : Vector3


func handle_input(event : InputEvent):
	if not has_contact:
		return
	if event.is_action_pressed("jump"):
		emit_signal("finished", "jump")
	elif event.is_action_pressed("roll"):
		emit_signal("finished", "roll")
	elif event.is_action_pressed("melee"):
		emit_signal("finished", "melee")
	elif event.is_action_pressed("reload") and owner.shooting.can_reload():
		emit_signal("finished", "reload")
	elif event.is_action_pressed("special_weapon") and owner.shooting.get_node("LaunchGrenade").can_throw(): # owner.can_shoot no cal
		emit_signal("finished", "throw_grenade")


func update_walk_anim(delta) -> void:
	var walk := Vector2(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"), Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	owner.get_node("AnimationTree").set("parameters/StateMachine/walk/move/blend_position", lerp(owner.get_node("AnimationTree").get("parameters/StateMachine/walk/move/blend_position"), walk, 20 * delta))
