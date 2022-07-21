extends RigidBody

func _ready():
	#apply_impulse(Vector3(randf(), .1, randf()) - Vector3.ONE * .5, -translation.normalized() / 5 + Vector3.UP * 6)
	apply_impulse(Vector3(randf(), .1, randf()) - Vector3.ONE * 500, -translation.normalized() / 5)
