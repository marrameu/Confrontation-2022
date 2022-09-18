extends Bullet
class_name MissileBullet

@export var rotate_speed := 50
var target : Node3D
var reached := false


func move(delta):
	if target and weakref(target).get_ref():
		if not reached:
			if position.distance_to(target.position) < 10:
				reached = true
			var desired_orient = global_transform.looking_at(target.position, Vector3.UP).basis
			global_transform.basis = Basis(Quaternion(global_transform.basis).slerp(Quaternion(desired_orient), rotate_speed * delta))
		position += delta * -global_transform.basis.z * bullet_velocity
	else:
		position += delta * direction * bullet_velocity
