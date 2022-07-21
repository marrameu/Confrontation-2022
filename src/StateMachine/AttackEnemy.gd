extends "AIShipState.gd"

var out_of_range_timer : Timer

var enemy : Spatial
var enemy_wr : WeakRef

var attack_rel_pos : Vector3
var total_attack_pos : Vector3

var get_away_from_the_enemy := true
var has_reached_enemy := false


func _ready():
	out_of_range_timer = Timer.new()
	add_child(out_of_range_timer)
	out_of_range_timer.connect("timeout", self, "_on_OutOfRangeTimer_timeout")


func enter():
	print(owner, " entered ", name)
	set_enemy()


func update(_delta):
	if enemy_wr and enemy_wr.get_ref():
		if has_reached_enemy and enemy.translation.distance_to(owner.translation) > 1500:
			emit_signal("finished", "choose_objective")
		attack_current_enemy()
	else:
		print("no enemy")
		emit_signal("finished", "choose_objective")
		"""
		var t = Timer.new()
		t.set_wait_time(rand_range(2, 4))
		self.add_child(t)
		t.start()
		t.connect("timeout", self, "enter")
		connect("finished", t, "queue_free")
		"""


func attack_current_enemy():
	owner.shooting.wants_shoots[0] = true
	owner.shooting.wants_shoots[1] = false
	
	if enemy_wr and enemy_wr.get_ref():
		if has_reached_enemy:
			if get_away_from_the_enemy:
				owner.input.des_throttle = 1.0
				owner.input.target = total_attack_pos
				if owner.translation.distance_to(owner.input.target) < 100: # distancia a la attack pos
					get_away_from_the_enemy = false
			else: # disa
				if not owner.shooting.enemy_in_range and out_of_range_timer.is_stopped():
					out_of_range_timer.wait_time = 10#rand_range(5, 14)
					out_of_range_timer.start()
					#no cal - elif owner.get_node("Shooting").enemy_in_range:
					#	timer.stop()
					# girar de pressa
				owner.input.des_throttle = 0.4
				owner.input.target = enemy.translation
		else:
			owner.input.des_throttle = 1.0
			owner.input.target = enemy.translation + attack_rel_pos # q si no sumes la relativa es xoquen
			if owner.translation.distance_to(enemy.translation) < 700:#400: # distancia a l'enemic
				has_reached_enemy = true
				total_attack_pos = enemy.translation + attack_rel_pos


func set_enemy():
	enemy = owner.shooting.target
	enemy_wr = weakref(enemy)
	has_reached_enemy = false
	get_away_from_the_enemy = true
	change_rel_pos()


func _on_OutOfRangeTimer_timeout():
	if enemy_wr and enemy_wr.get_ref():
		change_rel_pos()
		total_attack_pos = enemy.translation + attack_rel_pos
		get_away_from_the_enemy = true


func change_rel_pos():
	attack_rel_pos = Vector3(rand_range(-200, 200), rand_range(-200, 200), rand_range(-200, 200))


# si persegueix un enemic però li'n apareix un altre per davant, q ataqui al de devant
func _on_ShootingArea_body_entered(body):
	return
	if body != enemy and body.is_in_group("Ships"):
		if body.pilot_man.blue_team != owner.pilot_man.blue_team:
			set_enemy()


func exit():
	owner.shooting.target = null
