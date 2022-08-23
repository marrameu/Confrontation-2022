extends KinematicBody

signal entered_ship
signal entered_vehicle
signal died

onready var shooting := $Shooting

var pilot_man : PilotManager
var blue_team : bool

var mouse_movement := Vector2()

var can_aim := true # per a quan mori
var can_rotate := true
var can_shoot := true
var can_change_weapon := true

var dead := false


func _ready():
	blue_team = pilot_man.blue_team


func _physics_process(delta):
	if get_viewport().get_camera().owner.zooming:
		$AnimationTree.set("parameters/StateMachine/walk/move/4/aim/blend_amount", lerp($AnimationTree.get("parameters/StateMachine/walk/move/4/aim/blend_amount"), 1, 20 * delta))
	else:
		$AnimationTree.set("parameters/StateMachine/walk/move/4/aim/blend_amount", lerp($AnimationTree.get("parameters/StateMachine/walk/move/4/aim/blend_amount"), 0, 20 * delta))
	if can_rotate:
		var des_transform := global_transform.basis.slerp(get_tree().current_scene.get_node("CameraBase").global_transform.basis, 0.15 * delta * 60)
		rotation.y = des_transform.get_euler().y
		orthonormalize()
		#inverse kinematics


func _on_HealthSystem_die(attacker):
	var t = Timer.new()
	t.set_wait_time(5)
	self.add_child(t)
	t.start()
	t.connect("timeout", self, "die")
	$StateMachine._change_state("dead") # mirar com ho fa el gdquest
	# camera


func die():
	emit_signal("died")
	queue_free()


func _on_damagable_hit():
	# fer-ho millor amb senyals més ednavant i %
	$"%Weapons".get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("hit")


func _on_headshot():
	$"%Weapons".get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("killed")


func _on_enemy_died(attacker):
	if attacker == self:
		yield(get_tree(), "idle_frame") # pq no se'l mengi el headshot
		$"%Weapons".get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("red_hitmarker")


func _on_MeleeHitBox_area_entered(area):
	if area == $HurtBox:
		return
	if area.owner.blue_team == blue_team:
		return
	area.owner.get_node("HealthSystem").take_damage(25)
	# connect healthsystem die _on_enemy_died
	_on_damagable_hit()
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
