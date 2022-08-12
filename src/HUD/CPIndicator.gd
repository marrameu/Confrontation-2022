extends TextureProgress


var cp : CommandPost


func init(new_cp):
	cp = new_cp
	if cp.is_in_group("OrbitalCannonCP"):
		$TextureRect.show()


func _process(delta):
	if cp.m_team == 0:
		tint_progress = Color.white
		$TextureRect.modulate = Color.white
	elif cp.m_team == 1:
		tint_progress = Color.red
		$TextureRect.modulate = Color.red
	elif cp.m_team == 2:
		tint_progress = Color.blue
		$TextureRect.modulate = Color.blue
	
	var max_valor = 0
	for valor in cp.team_count:
		if valor > max_valor:
			max_valor = valor
			if valor == cp.team_count[0]:
				tint_progress = Color.red
				if cp.m_team == 1:
					$TextureRect.modulate = Color.red
				value = valor
			elif valor == cp.team_count[1]:
				tint_progress = Color.blue
				if cp.m_team == 2:
					$TextureRect.modulate = Color.blue
				value = valor
			else:
				value = 0
