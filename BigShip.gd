extends KinematicBody

signal destroyed
signal shields_down
signal shields_recovered

export var red_mat : Material
export var blue_mat : Material

export var blue_team : bool = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if blue_team:
		$Mesh.material_override = blue_mat
	else:
		$Mesh.material_override = red_mat


func _on_HealthSystem_die(attacker : Node):
	emit_signal("destroyed", self)
	queue_free()


func _on_HealthSystem_shield_die():
	emit_signal("shields_down", self)
	$ShieldMesh.hide()
	for turret in $Turrets.get_children():
		turret.get_node("HurtBox").monitorable = true


func _on_HealthSystem_shield_recovered():
	$ShieldMesh.show()
	for turret in $Turrets.get_children():
		turret.get_node("HurtBox").monitorable = false
	emit_signal("shields_recovered", self)


func _on_enemy_died(attacker : Node):
	if attacker == self:
		pass #print("he matat algú")
