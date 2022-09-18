extends "res://Turret.gd"

@export var cp_path : NodePath
@onready var cp : CommandPost = get_node(cp_path)

var target : Node3D


func _ready():
	$Timer.wait_time = 1/fire_rate


func _process(delta):
	if (cp.m_team == 1 or cp.m_team == 2):
		if not target or not weakref(target).get_ref():
			target = update_target(cp.m_team == 2)
			wants_shoot = false
		else:
			if target.get_node("HealthSystem").shield < 2500:
				if not $Timer.is_stopped():
					$Timer.stop()
				wants_shoot = false
				return
			if $Timer.is_stopped():
				$Timer.start()
			$Node3D.look_at(target.position, Vector3.UP)
	elif cp.m_team == 0 and not $Timer.is_stopped():
		$Timer.stop()
		target = null
		wants_shoot = false


func shoot():
	$AnimationPlayer.play("Shoot")


func shoot_anim():
	super.shoot()


func update_target(blue : bool) -> Node3D:
	#for support_ship in get_tree().get_nodes_in_group("SupportShips"):
	#	if support_ship.blue_team != blue:
	#		return support_ship
	for capital_ship in get_tree().get_nodes_in_group("CapitalShips"):
		if capital_ship.blue_team != blue:
			return capital_ship
	return null


func _on_Timer_timeout():
	wants_shoot = true


func set_bullets_shooter(bullet : Bullet):
	bullet.init(self, cp.m_team == 2)
