extends Spatial
class_name Gun

"""
Serveix tant a jugadors com a bots ja que l'unic necesari per disparar es
canviar la variable _shooting a true.

Té un raycast per a determinar on ha de dsisparar, en el cas de la IA,
el raycast es reposiciona al seu centre, mentrés que en els jugadors aquest 
es posiciona en la càmara. En el futur no serà necesari reposicionar-ho.

També duu un Audio3D com a fill per al só de dispar

Emet quatre senyals: shoot, quan el dispar té lloc;
hit, quan el raycast col·lisiona amb qualsevol objecte;
shot, quan el dispar té lloc amb el dany normal; headshot, quan el dispar
té lloc amb el dany especial o dany 'headshot'.

---

S'hauria de crear una variable per a determinar el retrocés.

Com fer que el so se sincronitzi online? Senyals?
"""

signal shoot
signal hit
signal shot
signal headshot

export var bullet_scene : PackedScene = preload("res://src/Bullets/Bullet.tscn")
const hit_scene : PackedScene = preload("res://src/Troops/Weapons/Particles/HitParticles.tscn")

export var continuous := true
export var fire_rate := 5.0

export var shoot_range := 500
export var offset := Vector2(30, 30)

export var shot_damage := 25
export var headshot_damage := 50

export var recoil_force := Vector2.ONE

var _next_time_to_fire := 0.0

var m_team := 0
var shooting := false

var time := 0.0

func _ready() -> void:
	m_team = 0
	if get_tree().has_network_peer():
		if not is_network_master():
			$HUD/Crosshair.queue_free()


func _process(delta : float) -> void:
	if get_tree().has_network_peer():
		if not is_network_master():
			return
	
	time += delta
	
	if shooting and time >= _next_time_to_fire:
		_next_time_to_fire = time + 1.0 / fire_rate
		_shoot()
	
	#if not shooting:
	#	cam.get_parent().stop_shake_camera()


func _shoot() -> void:
	emit_signal("shoot")
	
	if not continuous:
		shooting = false
	
	#$Audio.play()
	
	var vector := Vector2(rand_range(-offset.x, offset.x), rand_range(-offset.y, offset.y))
	vector = vector.length() * vector.normalized()
	$RayCast.cast_to = Vector3(vector.x, vector.y, shoot_range)
	
	var bullet : ShipBullet
	bullet = bullet_scene.instance()
	bullet.shooter = owner
	
	get_tree().current_scene.add_child(bullet)
	
	var shoot_from : Vector3 = global_transform.origin # Pistola
	bullet.global_transform.origin = shoot_from
	bullet.connect("damagable_hit", owner, "_on_damagable_hit")
	
	if $RayCast.is_colliding():
		var shoot_target = $RayCast.get_collision_point()
		
		bullet.direction = (shoot_target - shoot_from).normalized()
		bullet.look_at(shoot_target, Vector3.UP)
	else:
		bullet.direction = -get_viewport().get_camera().global_transform.basis.z
		bullet.look_at(global_transform.origin - get_viewport().get_camera().global_transform.basis.z, Vector3.UP)
	
	
	$RayCast.cast_to = Vector3(0, 0, shoot_range)


sync func _hit(collider_path : NodePath, point : Vector3) -> void:
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	
	# Consumeix molt rendiment instanciar les particules
	var hit : CPUParticles = hit_scene.instance()
	current_scene.add_child(hit)
	hit.global_transform.origin = point
	
	emit_signal("hit", point)
	
	if not get_node(collider_path):
		return
	
	if get_tree().has_network_peer():
		if not get_tree().is_network_server():
			return
	
	var collider : CollisionObject = get_node(collider_path)
	var damage := shot_damage
	
	if collider.is_in_group("Damagable"):
		if collider.is_in_group("Troops"):
			if collider.pilot_man.blue_team == owner.pilot_man.blue_team:
				return
			else:
				if point.y > collider.get_global_transform().origin.y + 1.2:
					damage = headshot_damage
					emit_signal("headshot", collider_path)
				else:
					emit_signal("shot", collider_path)
		else:
			emit_signal("shot", collider_path)
		
		if get_tree().has_network_peer():
			collider.get_node("HealthSystem").rpc("take_damage", damage)
		else:
			collider.get_node("HealthSystem").take_damage(damage)
		
	elif collider.is_in_group("Ships"):
		emit_signal("shot", collider_path)
		
		if get_tree().has_network_peer():
			collider.get_node("HealthSystem").rpc("take_damage", damage)
		else:
			collider.get_node("HealthSystem").take_damage(damage)
