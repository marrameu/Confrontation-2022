extends KinematicBody

signal entered_ship
signal died

var pilot_man : PilotManager
var blue_team : bool

var mouse_movement := Vector2()

var can_aim := true # per a quan mori
var can_rotate := true
var can_shoot := true

var dead := false


func _ready():
	blue_team = pilot_man.blue_team


func _physics_process(delta):
	if get_viewport().get_camera().owner.zooming:
		$AnimationTree.set("parameters/walk/3/aim/blend_amount", lerp($AnimationTree.get("parameters/walk/3/aim/blend_amount"), 1, 20 * delta))
	else:
		$AnimationTree.set("parameters/walk/3/aim/blend_amount", lerp($AnimationTree.get("parameters/walk/3/aim/blend_amount"), 0, 20 * delta))
	if can_rotate:
		var des_transform := global_transform.basis.slerp(get_tree().current_scene.get_node("CameraBase").global_transform.basis, 0.15 * delta * 60)
		rotation.y = des_transform.get_euler().y
		orthonormalize()
		#inverse kinematics


func _on_HealthSystem_die(attacker):
	queue_free()
	emit_signal("died")


func _on_damagable_hit():
	# fer-ho millor amb senyals més ednavant i %
	$Shooting/Weapons.get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("hit")


func _on_headshot():
	$Shooting/Weapons.get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("killed")


func _on_enemy_died():
	$Shooting/Weapons.get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("red_hitmarker")


func _on_MeleeHitBox_area_entered(area):
	if area == $HurtBox:
		return
	area.owner.get_node("HealthSystem").take_damage(15)
