extends CanvasLayer

onready var lock_target_info := $LockTargetInfo
onready var lock_target_nickname := $LockTargetInfo/Nickname
onready var lock_target_dist := $LockTargetInfo/Distance
onready var lock_target_life_bar := $LockTargetInfo/LifeBar
onready var lock_target_info_center_pos : Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))/2 - lock_target_info.rect_size/2

onready var cursor := $Center/Cursor
onready var crosshair := $Center/Crosshair
onready var cursor_center_pos : Vector2 = $Center.rect_size / 2 - cursor.rect_size / 2
onready var crosshair_center_pos : Vector2 = $Center.rect_size / 2 - crosshair.rect_size / 2

onready var damage_indicators := $Center/DamageIndicators

const damage_indicator_scene : PackedScene = preload("res://src/HUD/ShipDamageIndicator.tscn")

# Tots els nodes de la nau agafen l'input des d'aquí, millor que l'agafin des del node PlayerInput
var cursor_input := Vector2()

var _cursor_visible := false
var _cursor_limit := 450
var _crosshair_limit := 300
var _min_position := 20

var mouse_movement : Vector2


func _ready() -> void:
	make_visible(false)
	"""
	if LocalMultiplayer.number_of_players > 1:
		# Canviar l'escala d'alguns objectes
		$Center/CursorPivot/Cursor.rect_scale = Vector2(1.5, 1.5)
		$Center/Crosshair.rect_scale = Vector2(1.5, 1.5)
		$LifeBar.rect_scale = Vector2(2.25, 2.25) # No coincideix amb la del jugador
		$Indicators/LeaveIndicator.rect_scale = Vector2(2, 2)
		$Indicators/LandingIndicator.rect_scale = Vector2(2, 2)
		
		# Variable per a la sensibilitat en el mode multijugador, aquesta es multiplica per 2?
	"""


func _process(delta : float) -> void:
	if get_tree().has_network_peer():
		if get_parent().is_player:
			if get_parent().player_id != get_tree().get_network_unique_id():
				return
	
	$DieInfo.visible = owner.dead
	if owner.dead or owner.is_player_or_ai != 1:
		make_visible(false)
		return
	
	#Utilities.canvas_scaler(get_parent().number_of_player, self)
	
	if Input.is_key_pressed(KEY_F1):
		_cursor_visible = true
	elif Input.is_key_pressed(KEY_F2):
		_cursor_visible = false
	
	if not _cursor_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	
	
	update_center(delta)
	
	
	var target : Spatial = owner.shooting.lock_target
	if target and weakref(target).get_ref():
		lock_target_info.show()
		lock_target_nickname.text = target.name
		lock_target_dist.text = str(int(owner.translation.distance_to(target.translation)))
		if target.is_in_group("BigShips") and not target.get_node("HealthSystem").shield:
			var time_left = target.get_node("HealthSystem/ShieldTimer").time_left
			var wait_time = target.get_node("HealthSystem/ShieldTimer").wait_time
			lock_target_life_bar.value = (1.0 - (time_left / wait_time)) * 100
		else:
			lock_target_life_bar.value = (float(target.get_node("HealthSystem").shield) / float(target.get_node("HealthSystem").MAX_SHIELD)) * 100
		lock_target_life_bar.get_node("LifeBar").value = (float(target.get_node("HealthSystem").health) / float(target.get_node("HealthSystem").MAX_HEALTH)) * 100
		
		if not (owner.cam as Camera).is_position_behind(target.translation):
			lock_target_info.rect_position = (owner.cam as Camera).unproject_position(target.global_transform.origin) - Vector2(lock_target_info.rect_size / 2) + Vector2.UP * 80
			lock_target_info.rect_position = (lock_target_info.rect_position - lock_target_info_center_pos).clamped(500) + lock_target_info_center_pos
		else:
			var direction := Vector3(target.translation - owner.translation).normalized()
			var x = direction.dot(owner.global_transform.basis.x)
			var y = direction.dot(owner.global_transform.basis.y)
			var prova = Vector2(-x, -y).normalized()
			lock_target_info.rect_position = (prova * 500 - lock_target_info_center_pos).clamped(500) + lock_target_info_center_pos
			
			# així 100% q no
			#lock_target_info.rect_position = (owner.cam as Camera).unproject_position(target.translation) - Vector2(lock_target_info.rect_size / 2) + Vector2.UP * 80
			#lock_target_info.rect_position = (lock_target_info.rect_position - lock_target_info_center_pos).clamped(500) + lock_target_info_center_pos
			
			#lock_target_info.rect_position = (lock_target_info_center_pos + Vector2(x, y)*80000000).clamped(500) + lock_target_info_center_pos
		
		# ES POT FER MILLOR?
		if owner.shooting.locking_target_to_missile or owner.shooting.target_locked:
			$LockingTarget.show()
			if not $AnimationPlayer.is_playing() and owner.shooting.locking_target_to_missile:
				$AnimationPlayer.playback_speed = 1/owner.shooting.locking_time
				$AnimationPlayer.play("LockingTarget")
			if not (owner.cam as Camera).is_position_behind(target.translation):
				$LockingTarget.rect_position = (owner.cam as Camera).unproject_position(target.translation) - Vector2($LockingTarget.rect_size / 2)
		else:
			#$LockingTarget.rect_size.x = 140 # sembla q no cal
			$LockingTarget.hide()
			$AnimationPlayer.stop(true)
	else:
			#$LockingTarget.rect_size.x = 140 # sembla q no cal
			lock_target_info.hide()
			$LockingTarget.hide()
			$AnimationPlayer.stop(true)
	
	$ShieldLifeBar.value = float(get_node("../HealthSystem").shield) / float(get_node("../HealthSystem").MAX_SHIELD) * 100
	$ShieldLifeBar/LifeBar.value = float(get_node("../HealthSystem").health) / float(get_node("../HealthSystem").MAX_HEALTH) * 100
	
	var a = get_node("../Input").avaliable_turbos
	var rects = $SpeedBars/HBoxContainer2.get_children()
	for rect in rects:
		if a > 0:
			rect.color = Color("b79b5b")
			a -= 1
		else:
			rect.color = Color("48b6b6b6")
	
	var old_throttle_bar_value = $SpeedBars/ThrottleBar.value
	$SpeedBars/ThrottleBar.value = get_node("../Input").throttle * 100 
	
	if not owner.input.wants_turbo: # and not owner.input.drifting:
		# q no faci salts (frenar)
		if (old_throttle_bar_value > 70 and $SpeedBars/ThrottleBar.value <= 70 and $SpeedBars/ThrottleBar.value > 30) or (old_throttle_bar_value < 30 and $SpeedBars/ThrottleBar.value >= 30 and $SpeedBars/ThrottleBar.value < 70):
			# hi entra
			pass#$ThrottleInAudio.play()
		if (old_throttle_bar_value < 70 and $SpeedBars/ThrottleBar.value >= 70 and $SpeedBars/ThrottleBar.value > 30) or (old_throttle_bar_value > 30 and $SpeedBars/ThrottleBar.value <= 30 and old_throttle_bar_value <= 70):
			# en surt
			pass#$ThrottleOutAudio.play()
	
	"""
	var b = owner.transform.basis
	var v_len = owner.linear_velocity.length()
	var v_nor = owner.linear_velocity.normalized()
	var vel : Vector3
	vel.z = b.z.dot(v_nor) * v_len
	"""
	$SpeedBars/SpeedBar.value = owner.linear_velocity.length() / owner.physics.linear_force.z * 100
	$SpeedBars/SpeedBar.tint_progress = Color("966263ff") if not owner.input.turboing else Color("b79b5b")
	
	$Label.text = ""
	if owner.input.turboing:
		$Label.text += "turboing"
	if owner.input.drifting:
		$Label.text += "drifting"
	
	# passar a int
	$AmmoBars/AmmoBar.value = int(owner.shooting.ammos[0]) / owner.shooting.MAX_AMMOS[0] * 100
	$AmmoBars/AmmoBar.modulate = Color("9bffffff") if not owner.shooting.can_shoots[0] else Color("ffffff")
	$AmmoBars/AmmoBar2.value = int(owner.shooting.ammos[1]) / owner.shooting.MAX_AMMOS[1] * 100
	$AmmoBars/AmmoBar2.modulate = Color("9bffffff") if not owner.shooting.can_shoots[1] else Color("ffffff")
	
	"""
	# que no ho comprovi tota l'estona, amb un senyal anirià millor
	if get_parent().is_player:
		#$Indicators/LeaveIndicator.visible = get_parent().state == get_parent().State.LANDED
		
		if get_parent().state == get_parent().State.FLYING:
			#$Indicators/LandingIndicator.visible = get_parent().landing_areas > 0
			$LifeBar.show()
			$LifeBar.value = float(get_node("../HealthSystem").health) / float(get_node("../HealthSystem").MAX_HEALTH) * 100
		else:
			$Indicators/LandingIndicator.hide()
			$LifeBar.hide()
	"""


func _physics_process(delta):
	update_center(delta)
	mouse_movement = Vector2.ZERO


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative


func update_center(delta):
	if $Center.visible:
		crosshair.visible = !owner.input.turboing
		if not Settings.controller_input:
			cursor.visible = true
			cursor.rect_position += mouse_movement * delta * Settings.mouse_sensitivity
			crosshair.rect_position = cursor.rect_position - cursor_center_pos + crosshair_center_pos
			cursor.rect_position = (cursor.rect_position -  cursor_center_pos).clamped(_cursor_limit) + cursor_center_pos
			crosshair.rect_position = (crosshair.rect_position - crosshair_center_pos).clamped(_crosshair_limit) + crosshair_center_pos
			# tots aquests calculs pq al mig no és 0,0 sinó la meitat del pare :/
			
			if (cursor.rect_position - cursor_center_pos).length() > _min_position:
				cursor_input.x = (cursor.rect_position.x - cursor_center_pos.x) / _cursor_limit
				cursor_input.y = -(cursor.rect_position.y - cursor_center_pos.y) / _cursor_limit
			else:
				cursor_input = Vector2()
		else:
			cursor.visible = false
			crosshair.rect_position = (owner.cam as Camera).unproject_position(owner.global_transform.basis.z * owner.shooting.shoot_range + owner.translation) - $Center.rect_position - crosshair.rect_size/2


func _on_Shooting_shot():
	$Center/Crosshair/Parts/AnimationPlayer.play("Shoot")


func on_damagable_hit():
	pass
	$Center/Crosshair/HitMarkerParts/AnimationPlayer.play("hit")
	#$Center/Crosshair/HitMarkerParts/HitAudio.play()


func on_enemy_died():
	pass
	$Center/Crosshair/HitMarkerParts/AnimationPlayer.play("killed")
	#$Center/Crosshair/HitMarkerParts/KillAudio.play()


func _on_HealthSystem_die(attacker):
	$DieInfo.text = "Heu estat mort per " + attacker.name if attacker else "Heu estat mort"


func _on_HealthSystem_damage_taken(attacker : Spatial):
	if not attacker or not weakref(attacker).get_ref():
		return
	
	for child in damage_indicators.get_children():
		if child.attacker == attacker:
			child.restart_timer()
			return
	
	var damage_indicator = damage_indicator_scene.instance()
	damage_indicator.myself = owner
	damage_indicator.attacker = attacker
	damage_indicators.add_child(damage_indicator)


func make_visible(value : bool) -> void:
	for child in get_children():
		if "visible" in child:
			child.visible = value
