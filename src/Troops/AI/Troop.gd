extends CharacterBody3D

class_name Troop

signal died

# Materials
@export var body : NodePath

var pilot_man : PilotManager
var blue_team : bool

# Atack
var current_enemy : Node3D

var dead := false

 # terra i aire
var searching_ship := false



var nickname := "Troop"


# temproal
var wait_a_fcking_moment := false
var wait_to_init := true

var wait_to_shoot := false

@export var red_mat : Material
@export var blue_mat : Material

@onready var agent: NavigationAgent3D = $NavigationAgent3D


var can_shoot = false
var can_rotate = false


func _ready():
	$CheckCurrentEnemyTimer.wait_time = randf_range(2.5, 3.5)
	$AnimationTree.set("parameters/StateMachine/walk/move/3/blend_position", 1)
	blue_team = pilot_man.blue_team
	$TeamIndicator.material_override = blue_mat if blue_team else red_mat


func _physics_process(delta):
	#$PlayerMesh.moving = !$PathMaker.finished
	if get_tree().has_multiplayer_peer():
		if not get_tree().is_server():
			return
	
	if wait_to_init:
		return


func _on_HealthSystem_die(attacker) -> void:
	if get_tree().has_multiplayer_peer():
		if get_tree().is_server():
			($RespawnTimer as Timer).start()
			rpc("die")
	else:
		emit_signal("died")
		queue_free()
		# ($RespawnTimer as Timer).start()
		# die()


func set_material() -> void:
	if get_node("TroopManager").m_team == get_node("/root/Main").local_players[0].get_node("TroopManager").m_team:
		get_node(body).set_surface_override_material(2, load("res://assets/models/mannequiny/Azul_R.material"))
	else:
		get_node(body).set_surface_override_material(4, load("res://assets/models/mannequiny/Azul_L.material"))


func _on_InitTimer_timeout():
	wait_to_init = false
	$StateMachine.set_active(true)
	$AIStateMachine.set_active(true)


func _on_damagable_hit():
	pilot_man.points += 10


func _on_headshot():
	pilot_man.points += 20


func _on_enemy_died(attacker):
	if attacker == self:
		pilot_man.points += 100
	else:
		# assistència, desonenectar el senyal després de 5 segons
		pilot_man.points += 50


func _on_MeleeHitBox_area_entered(area):
	pass # Replace with function body.
