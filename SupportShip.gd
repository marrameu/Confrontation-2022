extends "res://BigShip.gd"


onready var original_x = translation.x


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if blue_team != PlayerInfo.player_blue_team:
		$SupportArea.hide()
	#tmb q s'amagui si el jugador és lluny


func _physics_process(delta):
	# si els escuts de la nau capital enemiga o la pròpia estan desactivats -> màx endavant o màx enradere
	if not get_node_or_null("/root/Level"):
		return # DebugLVl
	
	var des_x : float
	if original_x < 0:
		des_x = max(get_node("/root/Level").middle_point * 1.75 + original_x, original_x - 500)
	else:
		des_x = min(get_node("/root/Level").middle_point * 1.75 + original_x, original_x + 500)
	
	var collider
	if translation.x > des_x:
		move_and_collide(Vector3(-30 * delta, 0, 0))
	elif translation.x < des_x:
		move_and_collide(Vector3(30 * delta, 0, 0))
	#if collider:
	#	if collider.is_in_group("Asteroids"):
	#		collider.get_node("HealthSystem").take_damage(99999)


func _on_SupportArea_body_entered(body):
	if body.blue_team == blue_team:
		body.get_node("HealthSystem").heal(99999999)
		body.get_node("HealthSystem").heal_shield(9999999)
		var a : int = 0
		for value in body.shooting.ammos:
			body.shooting.ammos[a] = body.shooting.MAX_AMMOS[a]
			if body.shooting.ease_ammos[a]:
				body.shooting.not_eased_ammos[a] = body.shooting.MAX_AMMOS[a]
			a += 1


func _on_SupportArea_body_exited(body):
	pass # Replace with function body.
