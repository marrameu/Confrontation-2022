extends Spatial


func _ready():
	$AnimationPlayer.play("rifleidle")


func play_foot_step() -> void:
	$FootstepAudio.pitch_scale = rand_range(0.8, 1.2)
	$FootstepAudio.play()
