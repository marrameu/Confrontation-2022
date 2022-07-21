extends CanvasLayer

const match_msg_scene : PackedScene = preload("res://src/HUD/MatchMessage.tscn")

export var blue_ship : NodePath
export var red_ship : NodePath

export var blue_support_ship1 : NodePath
export var blue_support_ship2 : NodePath

export var red_support_ship1 : NodePath
export var red_support_ship2 : NodePath

var middle_point_value := 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# fer-ho per senyals? (a la nau del jugador tmb?) o massa complciat
	update_lifebars(blue_ship, $Control/LifeBarBlueShield)
	update_lifebars(red_ship, $Control/LifeBarRedShield)
	update_lifebars(blue_support_ship1, $Control/BlueSupportShips/LifeBarBluedShield)
	update_lifebars(blue_support_ship2, $Control/BlueSupportShips/LifeBarBlueShield2)
	update_lifebars(red_support_ship1, $Control/RedSupportShips/LifeBarRedShield)
	update_lifebars(red_support_ship2, $Control/RedSupportShips/LifeBarRedShield2)
	$Control/MiddlePointBar.value = middle_point_value


func update_lifebars(ship_path : NodePath, shield_life_bar):
	var ship = get_node(ship_path)
	
	if not ship:
		return
	
	var ship_health = float(ship.get_node("HealthSystem").health)
	var ship_max_health = float(ship.get_node("HealthSystem").MAX_HEALTH)
	
	var ship_shield = float(ship.get_node("HealthSystem").shield)
	var ship_max_shield = float(ship.get_node("HealthSystem").MAX_SHIELD)
	
	var time_left = ship.get_node("HealthSystem/ShieldTimer").time_left
	var wait_time = ship.get_node("HealthSystem/ShieldTimer").wait_time
	
	
	
	shield_life_bar.get_node("LifeBar").value = ship_health / ship_max_health * 100
	if ship_shield:
		shield_life_bar.value = ship_shield / ship_max_shield * 100
	else:
		shield_life_bar.value = (1.0 - (time_left / wait_time)) * 100


func _on_big_ship_shields_down(ship):
	$VBoxContainer/Label.text = "ELS ESCUTS DE " + ship.name + " HAN ESTAT DESACTIVATS"


func add_match_message(msg : String, blue : bool):
	var new_match_msg = match_msg_scene.instance()
	new_match_msg.text = msg
	new_match_msg.get_node("TextureRect").modulate = Color("9b5454") if not blue else Color("545c9b")
	$MatchMessages.add_child(new_match_msg)
