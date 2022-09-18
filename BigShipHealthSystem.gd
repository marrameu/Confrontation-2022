extends HealthSystem


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


@rpc(any_peer, call_local) func take_damage(amount : int, obviar_shield : bool = false, attacker : Node = null) -> void:
	if not health == 0: #pq si no moriria de nou, per evitar possibles bugs més q res -diria-
		if shield > 0 and not obviar_shield:
			shield -= amount
			shield = max(0, shield)
			if shield <= 0:
				emit_signal("shield_die")
				$ShieldTimer.start()
		else:
			health -= amount
			health = max(0, health)
			if health <= 0:
				emit_signal("die", attacker)


func _on_ShieldTimer_timeout():
	shield = MAX_SHIELD
	emit_signal("shield_recovered")
