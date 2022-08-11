extends Spatial
class_name Bullet

signal damagable_hit

export var damage := 100
export var bullet_velocity := 700.0

var direction : Vector3
var shooter

var _hit := false
export var _time_alive := 3.5 #7.0
var _old_translation : Vector3


func _ready():
	connect("damagable_hit", shooter, "_on_damagable_hit")
	var m_hurtbox = shooter.get_node_or_null("HurtBox")
	if m_hurtbox:
		$RayCast.add_exception(m_hurtbox)


func _physics_process(delta):
	if _hit: # Per l'animació d'explosió
		return
	
	move(delta)
	check_collisions()
	
	_time_alive -= delta
	if _time_alive < 0:
		queue_free()
	
	_old_translation = translation


func move(delta):
	translation += delta * direction * bullet_velocity


func check_collisions():
	var long = translation.distance_to(_old_translation)
	var ray := $RayCast
	if ray.is_colliding():
		var body : CollisionObject = ray.get_collider()
		if body.is_in_group("HurtBox"):
			body = body.owner
			_hit(body)
		
		translation = ray.get_collision_point()
		$HitParticles.hide()
		$Explosion.show()
		# $AudioStreamPlayer3D2.play()
		$AnimationPlayer.play("explode")
		_hit = true
		return
	ray.cast_to = Vector3(0, 0, -long)


func _hit(body):
	if body.is_in_group("Troops") or body.is_in_group("Ships"):
		if body.pilot_man:
			if body.pilot_man.blue_team == shooter.pilot_man.blue_team:
				return
	
	emit_signal("damagable_hit") # s'ha de fer abans, si no es menja l'animació "killed"
	if not body.get_node("HealthSystem").is_connected("die", shooter, "_on_enemy_died"):
		body.get_node("HealthSystem").connect("die", shooter, "_on_enemy_died")
	body.get_node("HealthSystem").take_damage(damage, false, shooter)


func _on_VisibilityNotifier_screen_entered():
	pass
	#visible = true


func _on_VisibilityNotifier_screen_exited():
	pass
	#visible = false