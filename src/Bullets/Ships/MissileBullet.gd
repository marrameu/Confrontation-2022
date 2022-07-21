extends ShipBullet
class_name MissileBullet

export var rotate_speed := 50
var target : Spatial
var reached := false


func move(delta):
	if target and weakref(target).get_ref():
		if not reached:
			if translation.distance_to(target.translation) < 10:
				reached = true
			var desired_orient = global_transform.looking_at(target.translation, Vector3.UP).basis
			global_transform.basis = Basis(Quat(global_transform.basis).slerp(Quat(desired_orient), rotate_speed * delta))
		translation += delta * -global_transform.basis.z * bullet_velocity
	else:
		translation += delta * direction * bullet_velocity
