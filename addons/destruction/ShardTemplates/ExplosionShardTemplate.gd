extends RigidBody3D

func _ready():
	#apply_impulse(-position.normalized() / 5 + Vector3.UP * 6, Vector3(randf(), .1, randf()) - Vector3.ONE * .5)
	apply_impulse(-position.normalized() / 5, Vector3(randf(), .1, randf()) - Vector3.ONE * 500)
