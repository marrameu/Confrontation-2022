extends Node

var enemies := []

func _ready() -> void:
	pass

func _process(_delta):
	enemies = []
	for body in $Area.get_overlapping_bodies():
		if body.is_in_group("Troops"):
			if body.pilot_man.blue_team != owner.pilot_man.blue_team:
				var health_system : Node = body.get_node("HealthSystem")
				if health_system.health > 0:
					enemies.push_back(body)
	
	if enemies.size() > 0 and not get_parent().current_enemie:
		get_parent().current_enemie = enemies[0]
	if get_parent().current_enemie:
		if get_parent().current_enemie.translation.distance_to(get_parent().translation) > 30:
			get_parent().current_enemie = null
