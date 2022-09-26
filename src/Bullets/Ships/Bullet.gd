extends Node3D
class_name Bullet

signal damagable_hit

@export var damage := 100
@export var bullet_velocity := 700.0

var direction : Vector3
var shooter

var _hit := false
@export var _time_alive := 3.5 #7.0
var _old_translation : Vector3

var m_blue_team := false

var long := 0.0


func init(new_shooter, new_team):
	shooter = new_shooter
	m_blue_team = new_team


func _ready():
	$HitParticles.show() # solució temporal, el 1r frame les HitParticles de vegades no estan ben col·locades
	if shooter.has_method("_on_damagable_hit"):
		connect("damagable_hit",Callable(shooter,"_on_damagable_hit"))
	var m_hurtbox = shooter.get_node_or_null("HurtBox")
	$RayCast3D.add_exception(shooter)
	if m_hurtbox:
		$RayCast3D.add_exception(m_hurtbox)


func _physics_process(delta):
	if _hit: # Per l'animació d'explosió
		return
	
	_old_translation = global_position
	
	move(delta)
	
	_time_alive -= delta
	if _time_alive < 0:
		queue_free()
	
	
	check_collisions()


func move(delta):
	position += delta * direction * bullet_velocity


func check_collisions():
	
	long = global_position.distance_to(_old_translation)
	var exclude : Array
	if weakref(shooter).get_ref():
		exclude = [shooter.get_node("HurtBox")]
	var query := PhysicsRayQueryParameters3D.create(_old_translation, global_position, $RayCast3D.collision_mask, exclude)  # més d'un?
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	
	#var ray := $RayCast3D
	#if ray.is_colliding():
	if result:
		var body : Node3D = result.collider
		if body.is_in_group("HurtBox"):
			body = body.owner
			_on_hit(body)
		
		global_position = result.position
		$HitParticles.hide()
		$Explosion.show()
		$HitAudio.pitch_scale = randf_range(1, 1.7)
		$HitAudio.play()
		$AnimationPlayer.play("hit")
		_hit = true
		return
	#ray.target_position = Vector3(0, 0, -long)


func _on_hit(body) -> bool:
	if "blue_team" in body:
		if body.blue_team == m_blue_team:
			return false

	emit_signal("damagable_hit") # s'ha de fer abans, si no es menja l'animació "killed"
	if not weakref(shooter).get_ref():
		return false
	if shooter.has_method("_on_enemy_died"):
		if not body.get_node("HealthSystem").is_connected("die",Callable(shooter,"_on_enemy_died")):
			body.get_node("HealthSystem").connect("die",Callable(shooter,"_on_enemy_died"))
	body.get_node("HealthSystem").take_damage(damage, false, shooter)
	return true


func _on_VisibilityNotifier_screen_entered():
	pass
	#visible = true


func _on_VisibilityNotifier_screen_exited():
	pass
	#visible = false


func add_exception(body):
	$RayCast3D.add_exception(body)
