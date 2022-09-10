extends RigidBody

export var impulse := 25.0
export var damage := 300.0

var shooter

#func init(direction):
#	rotation = direction


func _ready():
	mode = RigidBody.MODE_RIGID
	apply_central_impulse(-global_transform.basis.z * impulse)
	$AnimationPlayer.play("explode")


func _on_Granade_body_entered(body):
	$BounceAudio.play()
