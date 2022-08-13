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

export var fire_rate := 5.0
var _next_time_to_fire := 0.0
var time := 0.0

export var shoot_range := 500
export var offset := Vector2(30, 30)

export var recoil_force := Vector2.ONE

export var MAX_AMMO := 50.0
var ammo : float
var not_eased_ammo : float
export var reload_per_sec := 0.0 #  0.0 vol dir que no es recarrega automàticament

export var MAX_RELOAD_AMMO := 100.0 # només si no es recarrega auto (fer classes diferents?)
var reload_ammo : float

# var m_team := 0 wat?
var shooting := false

var active := false


func _ready() -> void:
	ammo = MAX_AMMO
	not_eased_ammo = MAX_AMMO
	reload_ammo = MAX_RELOAD_AMMO
	
	#m_team = 0
	if get_tree().has_network_peer():
		if not is_network_master():
			$HUD/Crosshair.queue_free()


func _process(delta : float) -> void:
	if get_tree().has_network_peer():
		if not is_network_master():
			return
	
	if not active:
		return
	
	auto_reload_ammo(delta)
	
	time += delta
	
	if shooting and time >= _next_time_to_fire and ammo >= 1:
		_next_time_to_fire = time + 1.0 / fire_rate
		_shoot()
	
	#if not shooting:
	#	cam.get_parent().stop_shake_camera()


func _shoot() -> void:
	emit_signal("shoot")
	
	#$Audio.play()
	
	ammo -= 1
	
	var vector := Vector2(rand_range(-offset.x, offset.x), rand_range(-offset.y, offset.y))
	vector = vector.length() * vector.normalized()
	$RayCast.cast_to = Vector3(vector.x, vector.y, shoot_range)
	$RayCast.force_raycast_update()
	
	var bullet : Bullet
	bullet = bullet_scene.instance()
	bullet.init(owner, owner.pilot_man.blue_team)
	
	get_tree().current_scene.add_child(bullet)
	
	var shoot_from : Vector3 = global_transform.origin # Pistola
	bullet.global_transform.origin = shoot_from
	
	if $RayCast.is_colliding():
		var shoot_target = $RayCast.get_collision_point()
		
		#bullet.direction = (shoot_target - shoot_from).normalized()
		bullet.look_at(shoot_target, Vector3.UP)
	else:
		bullet.look_at($RayCast.to_global($RayCast.cast_to), Vector3.UP)
	bullet.direction = -bullet.global_transform.basis.z
	
	
	$RayCast.cast_to = Vector3(0, 0, shoot_range)


func auto_reload_ammo(delta):
	if not reload_per_sec:
		return
	
	# el problema ara és que si fos continuous i deixés premut el botó, no es recarregaria per disparar ni una bala
	if not shooting and time >= _next_time_to_fire + 1:
		not_eased_ammo += delta * reload_per_sec
		ammo = clamp(pow(not_eased_ammo/MAX_AMMO, 3.0) * MAX_AMMO, 0, MAX_AMMO)
	else:
		var b = pow(ammo/MAX_AMMO, 1.0/3.0)
		not_eased_ammo = clamp(b*MAX_AMMO, 0, MAX_AMMO)


func reload_ammo():
	var tranfered_ammo = MAX_AMMO
	reload_ammo -= tranfered_ammo
	ammo += min(tranfered_ammo, MAX_AMMO - ammo)


func set_active(value : bool) -> void:
	active = value
	visible = value
