extends KinematicBody

signal entered_ship
signal died

var pilot_man : PilotManager

var mouse_movement := Vector2()

# var running := false
var can_shoot := false

var dead := false


func _physics_process(delta):
	var joystick_movement := 0.0
	var yaw_strenght : float = (joystick_movement + mouse_movement.x) * $CameraBase.rotate_speed_multipiler
	if yaw_strenght:
		rotate_yaw(yaw_strenght, delta)
	mouse_movement = Vector2.ZERO


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative * Settings.player_mouse_sensitivity


func rotate_yaw(strenght, delta):
	strenght *= delta
	rotate_y(-strenght)
	orthonormalize()


func _on_HealthSystem_die(attacker):
	queue_free()
	emit_signal("died")
