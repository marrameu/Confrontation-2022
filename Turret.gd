extends Node3D

var enemies = []
@export var bullet_scene : PackedScene = preload("res://src/Bullets/TurretBullet.tscn")

var wants_shoot := false

@export var fire_rate := 1.0
var next_time_to_fire := 0.0
var time_now := 0.0

@export var clamp_rot := 70.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# rotate
	if enemies:
		# make it slerp depenent de la dificultat
		$Node3D.look_at(enemies[0].position, $Node3D.global_transform.basis.y)
		$Node3D.rotation_degrees.z = 0
		$Node3D.rotation_degrees.x = clamp($Node3D.rotation_degrees.x, -clamp_rot, clamp_rot)
		$Node3D.rotation_degrees.y = clamp($Node3D.rotation_degrees.y, -clamp_rot, clamp_rot)


func _process(delta):
	time_now += delta
	
	if wants_shoot and time_now >= next_time_to_fire:
		if get_tree().has_multiplayer_peer():
			rpc("shoot")
		else:
			shoot()


@rpc(any_peer, call_local) func shoot() -> void:
	next_time_to_fire = time_now + 1.0 / fire_rate
	
	# Sound
	#$Audio.play()
	
	var bullet : Node3D
	bullet = bullet_scene.instantiate()
	set_bullets_shooter(bullet)
	
	get_tree().current_scene.add_child(bullet)
	var shoot_from : Vector3 = $"%BulletOrigin".global_transform.origin # Canons
	bullet.global_transform.origin = shoot_from
	bullet.direction = -$Node3D.global_transform.basis.z
	bullet.look_at($Node3D.global_transform.origin + -$Node3D.global_transform.basis.z, Vector3.UP)


func _on_HealthSystem_die(attacker):
	queue_free()


func set_bullets_shooter(bullet : Bullet):
	pass
