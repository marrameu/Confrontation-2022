extends HealthSystem

var recover_shield  := false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	if recover_shield:
		heal_shield(shield_repair_per_sec * delta)


# refer amb super.take_damage()
@rpc(any_peer, call_local) func take_damage(amount : int, obviar_shield : bool = false, attacker : Node = null) -> void:
	if not health == 0: #pq si no moriria de nou, per evitar possibles bugs més q res -diria-
		emit_signal("damage_taken", attacker)
		if shield > 0 and not obviar_shield:
			shield -= amount
			shield = max(0, shield)
			if shield <= 0:
				emit_signal("shield_die")
			recover_shield = false
			$ShieldTimer.start()
		else:
			health -= amount
			health = max(0, health)
			if health <= 0:
				emit_signal("die", attacker)


func _on_ShieldTimer_timeout():
	recover_shield = true
	emit_signal("shield_started_recovering")
