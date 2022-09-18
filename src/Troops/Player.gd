extends CharacterBody3D

signal entered_ship
signal entered_vehicle
signal died
signal points_added

@onready var shooting := $Shooting

var pilot_man : PilotManager
var blue_team : bool

var mouse_movement := Vector2()

var can_aim := true # per a quan mori
var can_rotate := true
var can_shoot := true
var can_change_weapon := true

var dead := false

# fall damage
var max_y := 0
@export var min_height := 5


func _ready():
	max_y = position.y
	blue_team = pilot_man.blue_team
	$StateMachine.set_active(true)


func _physics_process(delta):
	if get_viewport().get_camera_3d().owner.zooming:
		$AnimationTree.set("parameters/StateMachine/walk/move/4/aim/blend_amount", lerp($AnimationTree.get("parameters/StateMachine/walk/move/4/aim/blend_amount"), 1, 20 * delta))
	else:
		$AnimationTree.set("parameters/StateMachine/walk/move/4/aim/blend_amount", lerp($AnimationTree.get("parameters/StateMachine/walk/move/4/aim/blend_amount"), 0, 20 * delta))
	if can_rotate:
		var des_transform := global_transform.basis.slerp(get_tree().current_scene.get_node("%CameraBase").global_transform.basis.rotated(Vector3(0, 1, 0), deg_to_rad(180)), 0.15 * delta * 60)
		rotation.y = des_transform.get_euler().y
		orthonormalize()
		#inverse kinematics
	
	if "has_contact" in $StateMachine.current_state:
		if is_on_floor() and $StateMachine.current_state.has_contact:
			var jumped_height : float = max_y - position.y
			if jumped_height > min_height:
				get_node("HealthSystem").take_damage(jumped_height * 5)
			max_y = position.y
		elif not is_on_floor() and not $StateMachine.current_state.has_contact:
			if position.y > max_y:
				max_y = position.y


func _on_HealthSystem_die(attacker):
	var t = Timer.new()
	t.set_wait_time(5)
	self.add_child(t)
	t.start()
	t.connect("timeout",Callable(self,"die"))
	$StateMachine._change_state("dead") # mirar com ho fa el gdquest
	get_tree().current_scene.get_node("%CameraBase").killer = attacker


func die():
	emit_signal("died")
	queue_free()


func _on_damagable_hit():
	# fer-ho millor amb senyals més ednavant i %
	$"%Weapons".get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("hit")
	add_points(10)


func _on_headshot():
	$"%Weapons".get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("killed")
	add_points(20)


func _on_enemy_died(attacker):
	if attacker == self:
		await get_tree().idle_frame # pq no se'l mengi el headshot
		$"%Weapons".get_child($Shooting.current_weapon_ind).get_node("HUD/Pivot/HitMarkerParts/AnimationPlayer").play("red_hitmarker")
		add_points(100)
	else:
		# assistència, desonenectar el senyal després de 5 segons
		add_points(50)


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


func add_points(points : int) -> void:
	emit_signal("points_added", points)
	pilot_man.points += points
