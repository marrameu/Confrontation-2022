extends KinematicBody

class_name Troop

signal died

# Materials
export var body : NodePath

var pilot_man : PilotManager
var blue_team : bool

# Atack
var current_enemy : Spatial

var dead := false

 # terra i aire
var searching_ship := false



var nickname := "Troop"

# Networking
puppet var slave_position : = Vector3()
puppet var slave_rotation : = 0.0

# temproal
var wait_a_fcking_moment := false
var wait_to_init := true

var wait_to_shoot := false

export var red_mat : Material
export var blue_mat : Material

onready var agent: NavigationAgent = $NavigationAgent


func _ready():
	$AnimationTree.set("parameters/StateMachine/walk/move/3/blend_position", 1)
	blue_team = pilot_man.blue_team
	$TeamIndicator.material_override = blue_mat if blue_team else red_mat


func _physics_process(delta):
	#$PlayerMesh.moving = !$PathMaker.finished
	if get_tree().has_network_peer():
		if not get_tree().is_network_server():
			return
	
	if wait_to_init:
		return


func _on_HealthSystem_die(attacker) -> void:
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			($RespawnTimer as Timer).start()
			rpc("die")
	else:
		emit_signal("died")
		queue_free()
		# ($RespawnTimer as Timer).start()
		# die()


func set_material() -> void:
	if get_node("TroopManager").m_team == get_node("/root/Main").local_players[0].get_node("TroopManager").m_team:
		get_node(body).set_surface_material(2, load("res://assets/models/mannequiny/Azul_R.material"))
	else:
		get_node(body).set_surface_material(4, load("res://assets/models/mannequiny/Azul_L.material"))



func _on_InitTimer_timeout():
	wait_to_init = false
	$StateMachine.set_active(true)
	$AIStateMachine.set_active(true)

