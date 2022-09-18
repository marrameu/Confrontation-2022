extends TextureProgressBar


var cp : CommandPost


func init(new_cp):
	cp = new_cp
	if cp.is_in_group("OrbitalCannonCP"):
		$TextureRect.show()


func _process(delta):
	if not cp: # debug espai
		return
	
	if cp.m_team == 0:
		tint_progress = Color.WHITE
		$TextureRect.modulate = Color.WHITE
	elif cp.m_team == 1:
		tint_progress = Color.RED
		$TextureRect.modulate = Color.RED
	elif cp.m_team == 2:
		tint_progress = Color.BLUE
		$TextureRect.modulate = Color.BLUE
	
	var max_valor = 0
	for valor in cp.team_count:
		if valor > max_valor:
			max_valor = valor
			if valor == cp.team_count[0]:
				tint_progress = Color.RED
				if cp.m_team == 1:
					$TextureRect.modulate = Color.RED
				value = valor
			elif valor == cp.team_count[1]:
				tint_progress = Color.BLUE
				if cp.m_team == 2:
					$TextureRect.modulate = Color.BLUE
				value = valor
			else:
				value = 0
