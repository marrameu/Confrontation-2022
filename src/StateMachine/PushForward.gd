extends "AIShipState.gd"


func enter():
	print(owner, " entered ", name)
	owner.input.des_throttle = 1.0
	update_destination()


func update(delta):
	# turbo, si en té
	enemy_big_ships_wo_shields = clean_bigships_w_shields(enemy_big_ships_wo_shields)
	my_team_big_ships_wo_shields = clean_bigships_w_shields(my_team_big_ships_wo_shields)
	if enemy_big_ships_wo_shields or my_team_big_ships_wo_shields:
		emit_signal("finished", "choose_objective")
	
	if owner.translation.distance_to(owner.input.target) < 250:
		var closest_support_ship : Spatial = closest_big_ship("SupportShips")
		if closest_support_ship:
			owner.shooting.target = closest_support_ship
			print("support ship, fora!!")
			emit_signal("finished", "attack_big_ship")
		else:
			emit_signal("finished", "attack_cs")
		# emit_signal("finished", "choose_objective")
		# no faig choose_obj pq q passa si fa push forward i hi arriba però el middle point encara no?
		# i doncs si ja ha arribat a aquest punt i no sha trobat cap enemic, q ataqui les naus grans
	
	if get_node("/root/Level").middle_point < -get_parent().point_of_change or get_node("/root/Level").middle_point > get_parent().point_of_change:
		emit_signal("finished", "choose_objective")
	
	# No sé si això és pot optimitzar més (amb el ChooseObj)
	var closest_attack_ship : Spatial = closest_big_ship("AttackShips")
	if closest_attack_ship:
		if closest_attack_ship.translation.distance_to(owner.translation) < 1000:
			emit_signal("finished", "choose_objective")
	
	if number_of_my_team_ships() - number_of_enemy_ships() <= 2: # millor fer-ho en funció del middle point
		var closest_enemy = closest_enemy()
		if closest_enemy:
			emit_signal("finished", "choose_objective")
	
	var closest_enemy_to_cs = closest_enemy_to_cs()
	if closest_enemy_to_cs:
		emit_signal("finished", "choose_objective")


func update_destination():
	if owner.pilot_man.blue_team:
		owner.input.target = Vector3(-1500, 2000 + rand_range(-350, 350), rand_range(-700, 700))
	else:
		owner.input.target = Vector3(1500, 2000 + rand_range(-350, 350), rand_range(-700, 700))
