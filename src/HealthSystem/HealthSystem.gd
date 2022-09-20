extends Node
class_name HealthSystem

signal die
signal shield_die
signal shield_started_recovering
signal shield_recovered
signal damage_taken

@export var MAX_SHIELD : float = 0 # no caldria perquè l'escut, se suposa que no es pot regenerar -ah, calla, amb les caus sí-, però per a les health bars potser convindria
var shield : float = 0

@export var time_before_shield_repair : float= 5
@export var shield_repair_per_sec : float = 20

@export var MAX_HEALTH : float = 150 
# 150 Tropes d'assalt, 1200 Caces estelars, 800 Interceptors, 2100 Bombarders, 3600 Naus de transport, 600000 Creuers 
var health : float = 0


func _ready() -> void:
	if get_node_or_null("ShieldTimer"):
		$ShieldTimer.wait_time = time_before_shield_repair
	
	if health == 0:
		health = MAX_HEALTH
	
	shield = MAX_SHIELD


func _process(delta):
	pass


@rpc(any_peer, call_local) func take_damage(amount : int, obviar_shield : bool = false, attacker : Node = null) -> void:
	if not health == 0: #pq si no moriria de nou, per evitar possibles bugs més q res -diria-
		emit_signal("damage_taken", attacker)
		if shield > 0 and not obviar_shield:
			shield -= amount
			shield = max(0, shield)
			if shield <= 0:
				emit_signal("shield_die")
		else:
			health -= amount
			health = max(0, health)
			if health <= 0:
				emit_signal("die", attacker)


@rpc(any_peer, call_local) func heal(amount : float) -> void:
	health += amount
	health = min(health, MAX_HEALTH)


@rpc(any_peer, call_local) func heal_shield(amount : int) -> void:
	shield += amount
	shield = min(shield, MAX_SHIELD)
	if shield == MAX_SHIELD:
		emit_signal("shield_recovered") # pa q es aquest senyal?


func _on_ShieldTimer_timeout():
	pass
