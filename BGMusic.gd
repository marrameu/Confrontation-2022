extends AudioStreamPlayer


export(AudioStream) var audio_sfx1
export(AudioStream) var audio_sfx2
export(AudioStream) var audio_sfx3


# Called when the node enters the scene tree for the first time.
func _ready():
	var kk = randi() % 3
	match kk:
		0:
			stream = audio_sfx1
		1:
			stream = audio_sfx2
		2:
			stream = audio_sfx3
	# play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BGMusic_finished():
	pass # Replace with function body.
