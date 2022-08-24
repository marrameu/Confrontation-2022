extends Node

var mouse_movement : Vector2

var pitch := 0.0
var yaw := 0.0

func _physics_process(delta):
	if not owner.active:
		return
	pitch = clamp(mouse_movement.x + pitch, -250, 250) # 150?
	yaw = clamp(mouse_movement.y + yaw, -250, 250)
	mouse_movement = Vector2.ZERO


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative * Settings.player_mouse_sensitivity
