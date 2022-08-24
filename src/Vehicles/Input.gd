extends Node

var mouse_movement : Vector2

var pitch := 0.0
var yaw := 0.0

func _physics_process(delta):
	if not owner.active:
		return
	pitch = clamp(mouse_movement.x / 10 + pitch, -50, 50) # 150?
	yaw = clamp(mouse_movement.y / 10 + yaw, -50, 50)
	mouse_movement = Vector2.ZERO


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative * Settings.player_mouse_sensitivity
