extends CharacterBody3D
class_name TroopBase

func _ready() -> void:
	get_node("AnimationTree").get("parameters/StateMachine/playback").travel("walk")
