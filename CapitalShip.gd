extends "res://BigShip.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _ready():
	for ship_spawn in get_node("Hangar").get_node("%ShipSpawns").get_children():
		ship_spawn.blue_team = blue_team
	
	$SceneRoot/engines.material_override = blue_mat if blue_team else red_mat
	$SceneRoot/bottom.material_override = blue_mat if blue_team else red_mat
	$SceneRoot/up.material_override = blue_mat if blue_team else red_mat


func _process(delta):
	# UNA FORMA ÉS FER-HO AIXÍ, AMB %, L'ALTRA SERIA ESTENENT EL HEALTHSYSTEM I FENT QUE QUAN UN REP MAL (SENYAL DAMAGE TAKEN), L'ALTRE TMB
	var ship_health_percentage : float = float($HealthSystem.health)/$HealthSystem.MAX_HEALTH*100
	var core_health_percentage : float = float($Core/HealthSystem.health)/$Core/HealthSystem.MAX_HEALTH*100
	if ship_health_percentage < core_health_percentage:
		var amount : float = (core_health_percentage - ship_health_percentage)/100 * $Core/HealthSystem.MAX_HEALTH
		if amount > 1:
			$Core/HealthSystem.take_damage(amount)
	elif core_health_percentage < ship_health_percentage:
		$HealthSystem.take_damage((ship_health_percentage - core_health_percentage)/100 * $HealthSystem.MAX_HEALTH, true)


func _physics_process(delta):
	pass#move_and_collide(Vector3(10 * delta, 0, 0))


func _on_HealthSystem_die(attacker : Node):
	$Alarm.play()
	# animacions
	
	var t = Timer.new()
	t.set_wait_time(20)
	self.add_child(t)
	t.start()
	t.connect("timeout",Callable(self,"die"))


func die():
	$ExplosionArea/CollisionShape3D.disabled = false
	await get_tree().create_timer(1).timeout
	emit_signal("destroyed")
	queue_free()


func _on_ExplosionArea_area_entered(area):
	area.owner.get_node("HealthSystem").take_damage(999999, true)
