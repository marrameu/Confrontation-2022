extends Ship

var cam : Camera


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ShipMesh.visible = !Settings.first_person or dead
	$PlayerShipInterior.visible = Settings.first_person and not dead


func _on_damagable_hit():
	$PlayerHUD.on_damagable_hit()


func _on_enemy_died(attacker : Node):
	if attacker == self:
		$PlayerHUD.on_enemy_died()


func _on_HealthSystem_die(attacker : Node):
	dead = true
	print("HAS ESTAT MORT PER ", attacker)
	if attacker:
		cam.killer = (attacker)
	
	# animacions
	
	var t = Timer.new()
	t.set_wait_time(2)
	self.add_child(t)
	t.start()
	t.connect("timeout", self, "die")


func init(new_pilot_man : PilotManager):
	pilot_man = new_pilot_man
	set_team_color()
	$PlayerHUD.make_visible(true)
	mode = 0
