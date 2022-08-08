extends Node

signal activated_turboing

var pitch := 0.0
var yaw := 0.0
var roll := 0.0
var strafe := 0.0
var throttle := 0.5

# TURBO
var TURBO_RECHARGE_TIME := 3.0
var MAX_AVALIABLE_TURBOS : int = 5
var avaliable_turbos : int = 5#0

var turboing := false
var do_turbo = false
var drifting := false
var wants_turbo := false
var wants_drift := false
var can_turbo := false


func _process(delta):
	_recover_turbo()
	
	can_turbo = avaliable_turbos and owner.landing_areas < 1
	
	# BLOC 1
	if drifting:
		if wants_turbo and can_turbo:
			drifting = false
			$DriftTimer.stop() # per evitar possibles problemes
			do_turbo = true
	
	# BLOC 2 (ha d'anar sempre després, si no amb el comandament s'activa el turbo immediatament)
	if not turboing:
		if wants_turbo and can_turbo:
			do_turbo = true
			#$TurboAudio.play()
	else:
		if wants_drift:
			drifting = true
			do_turbo = false
			#$DriftAudio.play()
		# drifting = Input.is_action_pressed(drift_action) # just?
	
	if not drifting: # aquesta comprovació potser sorba una mica
		if turboing and do_turbo: # espera q arribi a turboing
			if $DrainTurboTimer.is_stopped():
				$DrainTurboTimer.start()
	else:
		if $DriftTimer.is_stopped():
			$DriftTimer.start() # fer-ho per temps o quan la vel arribi a gairebé 0
		if not $DrainTurboTimer.is_stopped():
			$DrainTurboTimer.stop()
			avaliable_turbos = clamp(avaliable_turbos - 1, 0, MAX_AVALIABLE_TURBOS)


func update_throttle(des_value : float, delta : float) -> void:
	des_value = clamp(des_value, 0.0, 1.0)
	
	var target := throttle
	var turbo_clamp := 2.0
	
	if drifting:
		target = 0.0
		throttle = 0.0
	elif do_turbo:
		target += delta
	elif throttle > 1: # espera abans de fer el clamp, si no, baixa a 1 de cop
		target -= delta
		# emit_signal("activated_turboing", false)
	else:
		turbo_clamp = 0.25 if owner.landing_areas >= 1 else 1.0
		if des_value > throttle:
			target += delta / 2
			target = max(throttle, target) # per si es passa (NO FUNCIONA QUAN BAIXEN ELS FPS!!!!)
		elif des_value < throttle:
			target -= delta / 2
			target = min(throttle, target) # per si es passa (NO FUNCIONA QUAN BAIXEN ELS FPS!!!!)
	
	target = clamp(target, 0.0, turbo_clamp) # TURBO_THROTTLE
	
	turboing = target > 1
	if target > 1 and throttle <= 1: # s'acaba d'activar el turbo
		emit_signal("activated_turboing", true)
	elif throttle > 1 and target <= 1:
		emit_signal("activated_turboing", false)
	
	throttle = target


func _on_ReloadTurboTimer_timeout():
	avaliable_turbos = clamp(avaliable_turbos + 1, 0, MAX_AVALIABLE_TURBOS)


func _recover_turbo():
	if MAX_AVALIABLE_TURBOS == avaliable_turbos or do_turbo or turboing:
		$ReloadTurboTimer.stop()
	else:
		if $ReloadTurboTimer.is_stopped():
			$ReloadTurboTimer.start()
		$ReloadTurboTimer.wait_time = TURBO_RECHARGE_TIME


func _on_DrainTurboTimer_timeout():
	#$TurboSwitchAudio.play()
	avaliable_turbos = clamp(avaliable_turbos - 1, 0, MAX_AVALIABLE_TURBOS)
	can_turbo = avaliable_turbos and owner.landing_areas < 1
	do_turbo = wants_turbo and can_turbo


func _on_DriftTimer_timeout():
	drifting = false
