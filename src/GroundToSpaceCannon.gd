extends "res://Turret.gd"

export var cp_path : NodePath
onready var cp : CommandPost = get_node(cp_path)

var target : Spatial


func _ready():
	$Timer.wait_time = 1/fire_rate


func _process(delta):
	if (cp.m_team == 1 or cp.m_team == 2):
		if $Timer.is_stopped():
			$Timer.start()
		if not target or not weakref(target).get_ref():
			target = update_target(cp.m_team == 2)
			wants_shoot = false
		else:
			$Spatial.look_at(target.translation, Vector3.UP)
	elif cp.m_team == 0 and not $Timer.is_stopped():
		$Timer.stop()
		target = null
		wants_shoot = false


func update_target(blue : bool) -> Spatial:
	for support_ship in get_tree().get_nodes_in_group("SupportShips"):
		if support_ship.blue_team != blue:
			return support_ship
	for capital_ship in get_tree().get_nodes_in_group("CapitalShips"):
		if capital_ship.blue_team != blue:
			return capital_ship
	return null


func _on_Timer_timeout():
	wants_shoot = true


func set_bullets_shooter(bullet : Bullet):
	bullet.init(self, cp.m_team == 2)
