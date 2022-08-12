extends "AIShipState.gd"

# CHOOSE OBEJCTIVE DESTRUCTION BATTLE

func enter():
	print(owner, " entered ", name)
	
	my_team_big_ships_wo_shields = clean_bigships_w_shields(my_team_big_ships_wo_shields)
	enemy_big_ships_wo_shields = clean_bigships_w_shields(enemy_big_ships_wo_shields)
	
	var aneu_guanyant := false
	var us_van_guanyant := false
	if get_node("/root/Level").middle_point < -get_parent().point_of_change:
		if owner.pilot_man.blue_team:
			aneu_guanyant = true
		else:
			us_van_guanyant = true
	elif get_node("/root/Level").middle_point > get_parent().point_of_change:
		if not owner.pilot_man.blue_team:
			aneu_guanyant = true
		else:
			us_van_guanyant = true
	
	for ship in my_team_big_ships_wo_shields:
		# aquestes comprovacions fa que vagi per ordre de priotritats
		if ship.is_in_group("CapitalShips") or ship.is_in_group("SupportShips"):
			get_parent().states_map["defend_bs"].target_ship = ship
			emit_signal("finished", "defend_bs")
			return
		elif ship.is_in_group("AttackShips"):
			if not aneu_guanyant: # si va guanyant, no cal que la defensi (IDEALMENT CALDRIA VEURE EN TOTES LES NAUS GRANS SI HI HA ALGÚ ATACANT-LA ABANS DE DEFENSAR-LA)
				get_parent().states_map["defend_bs"].target_ship = ship
				emit_signal("finished", "defend_bs")
				return
	for ship in enemy_big_ships_wo_shields:
		if ship.is_in_group("SupportShips") or ship.is_in_group("AttackShips"):
			owner.shooting.target = ship
			emit_signal("finished", "attack_big_ship")
			return
		elif ship.is_in_group("CapitalShips"):
			print("A PENETRAR-lA!!! ö")
	
	# TOTES LES NAUS GRANS TENEN ESCUTS
	if us_van_guanyant:
		var closest_attack_ship : Spatial = closest_big_ship("AttackShips")
		if closest_attack_ship:
			if closest_attack_ship.translation.distance_to(owner.translation) < 1000 and randi() % 2:
				owner.shooting.target = closest_attack_ship
				emit_signal("finished", "attack_big_ship")
				return
		
		var closest_enemy = closest_enemy()
		if closest_enemy:
			owner.shooting.target = closest_enemy
			emit_signal("finished", "attack_enemy")
			return
		
		var closest_enemy_to_cs = closest_enemy_to_cs() # no hauria de comprovar si és més a prop que ella
		if closest_enemy_to_cs:
			owner.shooting.target = closest_enemy_to_cs
			emit_signal("finished", "attack_enemy")
			return
		
		closest_enemy = closest_enemy(INF)
		if closest_enemy:
			owner.shooting.target = closest_enemy
			emit_signal("finished", "attack_enemy")
			return
		
	elif aneu_guanyant:
		print("nem guanyant")
		var closest_attack_ship : Spatial = closest_big_ship("AttackShips")
		if closest_attack_ship:
			if closest_attack_ship.translation.distance_to(owner.translation) < 1000:
				owner.shooting.target = closest_attack_ship
				emit_signal("finished", "attack_big_ship")
				print("ataca la nau d'atac!")
				return
		
		var closest_support_ship : Spatial = closest_big_ship("SupportShips")
		if closest_support_ship:
			owner.shooting.target = closest_support_ship
			print("support ship, fora!!")
			emit_signal("finished", "attack_big_ship")
		else:
			print("capital ship, fora!!")
			for cship in get_tree().get_nodes_in_group("CapitalShips"):
				if cship.blue_team != owner.pilot_man.blue_team:
					owner.shooting.target = cship
					emit_signal("finished", "attack_big_ship")
			if not closest_support_ship:
				print("MALAMENT RAI, LA CSHIP JA HA ESTAT DESTRUÏDA")
	else:
		# DIFERÈNCIA < 1500
		
		var closest_attack_ship : Spatial = closest_big_ship("AttackShips")
		if closest_attack_ship:
			if closest_attack_ship.translation.distance_to(owner.translation) < 1000 and randi() % 2:
				owner.shooting.target = closest_attack_ship
				emit_signal("finished", "attack_big_ship")
				return
		
		# potser, si costa molt avançar, fer que si no hi ha més que un o dos enemics vius (i tot l'equip teu viu, ço és, diferència de 3) ja podeu push forward
		if number_of_my_team_ships() - number_of_enemy_ships() <= 2: # millor fer-ho en funció del middle point
			var closest_enemy = closest_enemy()
			if closest_enemy:
				owner.shooting.target = closest_enemy
				emit_signal("finished", "attack_enemy")
				return
		
		var closest_enemy_to_cs = closest_enemy_to_cs()
		if closest_enemy_to_cs:
			owner.shooting.target = closest_enemy_to_cs
			emit_signal("finished", "attack_enemy")
			return
		
		emit_signal("finished", "push_forward")
		
		"""
		if randi() % 2:
			emit_signal("finished", "patrol_middle_point")
			print(owner.name, "patrol")
		else:
			emit_signal("finished", "attack_big_ship")
			print(owner.name, "attack big_ship")
		"""
