extends KinematicBody

signal entered_ship
signal died

var pilot_man : PilotManager

var mouse_movement := Vector2()

var can_aim := true # per a quan mori
var can_rotate := true
var can_shoot := true

var dead := false


func _physics_process(delta):
	var joystick_movement := 0.0
	var yaw_strenght : float = (joystick_movement + mouse_movement.x) * $CameraBase.rotate_speed_multipiler
	if yaw_strenght and can_aim:
		rotate_yaw(yaw_strenght, delta)
	mouse_movement = Vector2.ZERO
	if can_rotate:
		pass


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
