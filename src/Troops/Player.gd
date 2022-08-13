extends KinematicBody

signal entered_ship
signal died

var pilot_man : PilotManager

var mouse_movement := Vector2()

var can_aim := true # per a quan mori
var can_rotate := true
var can_shoot := true

var dead := false


func _physics_process(delta):
	if can_rotate:
		var des_transform := global_transform.basis.slerp(get_tree().current_scene.get_node("CameraBase").global_transform.basis, 0.15 * delta * 60)
		rotation.y = des_transform.get_euler().y
		orthonormalize()
		#inverse kinematics


func _on_HealthSystem_die(attacker):
	queue_free()
	emit_signal("died")


func _on_damagable_hit():
	pass


func _on_headshot():
	pass


func _on_enemy_died():
	pass


func _on_MeleeHitBox_area_entered(area):
	if area == $HurtBox:
		return
	area.owner.get_node("HealthSystem").take_damage(15)
