extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.vsync_enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$VBoxContainer/Fps.set_text(str(Performance.get_monitor(Performance.TIME_FPS)))
	$VBoxContainer/DrawCalls2.set_text(str(Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME)))
	#$VBoxContainer/Position.set_text(str($Camera.get_translation()))
	$VBoxContainer/Position.set_text(str(get_viewport().get_camera().get_translation()))

