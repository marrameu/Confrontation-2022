extends "AttackEnemy.gd"

var t : Timer

func enter():
	t = Timer.new()
	t.set_wait_time(rand_range(7, 14))
	self.add_child(t)
	t.connect("timeout", self, "update_point")
	connect("finished", t, "queue_free")
	
	update_point()


func update(_delta):
	if enemy_wr and enemy_wr.get_ref():
		attack_current_enemy()
		t.stop()
	else:
		check_for_close_enemies()
		if t.is_stopped(): # CAL QUE SIGUI TIMER? NI IDEA
			t.start()



func update_point():
	owner.input.target = Vector3(get_node("/root/Level").middle_point + rand_range(-1000, 1000), rand_range(-350, 350), rand_range(-700, 700))


func check_for_close_enemies(min_dist : float = 750.0):
	var clos_dist = min_dist
	var clos_enemy : Ship
	for ship in get_tree().get_nodes_in_group("Ships"):
		if ship.pilot_man.blue_team != owner.pilot_man.blue_team:
			var dist = owner.translation.distance_to(ship.translation)
			if dist < clos_dist:
				clos_dist = dist
				clos_enemy = ship
	if clos_enemy:
		set_enemy()
