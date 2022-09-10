extends CanvasLayer


const damage_indicator_scene : PackedScene = preload("res://src/HUD/TroopDamageIndicator.tscn")

export var launch_grenade_path : NodePath
onready var launch_grenade : Spatial = get_node(launch_grenade_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"%MyLifeBar".value = float(owner.get_node("HealthSystem").health) / owner.get_node("HealthSystem").MAX_HEALTH * 100
	$Alive/SpeiclaWeapons/TextureRect/Label.text = str(launch_grenade.ammo)


func _on_HealthSystem_damage_taken(attacker : Spatial):
	$RedRect.color.a = 0.08# = damage_taken/250?
	var tween := get_tree().create_tween()
	tween.tween_property($RedRect, "color:a", 0.0, 0.5)
	
	if not attacker or not weakref(attacker).get_ref():
		return
	
	for child in $"%DamageIndicators".get_children():
		if child.attacker == attacker:
			child.restart_timer()
			return
	
	var damage_indicator = damage_indicator_scene.instance()
	damage_indicator.attacker = attacker
	damage_indicator.myself = owner
	$"%DamageIndicators".add_child(damage_indicator)


func _on_HealthSystem_die(attacker):
	$Alive.hide()
	$DieInfo.show()
	$DieInfo.text = "Heu estat mort per " + attacker.name if attacker else "Heu estat mort"


func points_added(new_points : int):
	$Points.on_points_added(new_points)
