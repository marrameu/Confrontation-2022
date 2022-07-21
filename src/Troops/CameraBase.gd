extends Spatial

onready var init_cam_pos_x : float = -$CameraPosition.translation.x
onready var tween : Tween = $Tween

var mouse_movement := Vector2()

const CAMERA_X_ROT_MAX := 50
const CAMERA_X_ROT_MIN := -60

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("change_view"):
		move_camera()


func _physics_process(delta):
	var joystick_movement := 0.0
	var pitch_strenght := joystick_movement + mouse_movement.y
	if pitch_strenght:
		rotate_pitch(pitch_strenght, delta)
	mouse_movement = Vector2.ZERO


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative * Settings.player_mouse_sensitivity


func move_camera() -> void:
	var current_x = $CameraPosition.translation.x
	if current_x > 0:
		var _new_x = tween.interpolate_property($CameraPosition, "translation:x", current_x, -init_cam_pos_x, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		var _new_x = tween.interpolate_property($CameraPosition, "translation:x", current_x, init_cam_pos_x, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	var _start = tween.start()


func rotate_pitch(strenght, delta):
	var camera_x_rot = clamp(rotation.x + strenght * delta, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
	rotation.x = camera_x_rot
	orthonormalize()
