extends Node

signal bloom_toggled(value)
signal brightness_set(value)

var player_mouse_sensitivity := 0.2


# NAUS

var first_person := false

var mouse_sensitivity := 75.0
var joystick_sensitivity := 0.6
var controller_input := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("change_input"):
		controller_input = !controller_input

func toggle_fullscreen(toggle):
	ProjectSettings.set("display/window/size/fullscreen", toggle)

func toggle_bloom(value):
	emit_signal("bloom_toggled", value)

func toggle_FXAA(value):
	get_viewport().set_use_fxaa(value)
	
func select_MSAA(index):
	if index == 0:
		get_viewport().set_msaa(index)
	if index == 1:
		get_viewport().set_msaa(index)
	if index == 2:
		get_viewport().set_msaa(index)
	if index == 3:
		get_viewport().set_msaa(index)
	if index == 4:
		get_viewport().set_msaa(index)

func set_sharpen_value(value):
	get_viewport().set_sharpen_intensity(value)
	print(get_viewport().get_sharpen_intensity())

func set_brightness(value):
	emit_signal("brightness_set", value)

func toggle_MotionBlur(toggle):
	if toggle == false:
		get_parent().get_node("Level").get_node("Camera3D/motion_blur").hide()
	else:
		get_parent().get_node("Level").get_node("Camera3D/motion_blur").show()
