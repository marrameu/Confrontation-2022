extends Node

# Mouse
var mouse_position := Vector2()
var mouse_acceleration := Vector2() # Not ready

# Time
var time := 0.0

var first_person := false

func play_button_audio() -> void:
	var button_audio : AudioStreamPlayer = AudioStreamPlayer.new()
	button_audio.set_stream(preload("res://assets/audio/button_sfx.wav"))
	button_audio.connect("finished",Callable(button_audio,"queue_free"))
	var current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() -1)
	current_scene.add_child(button_audio)
	button_audio.play()


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position


func _process(delta : float) -> void:
	time = Time.get_ticks_msec() / 1000.0 # Pausa?
