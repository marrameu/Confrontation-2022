extends "res://BigShip.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _ready():
	$SceneRoot/engines.material_override = blue_mat if blue_team else red_mat
	$SceneRoot/bottom.material_override = blue_mat if blue_team else red_mat
	$SceneRoot/up.material_override = blue_mat if blue_team else red_mat


func _process(delta):
	# UNA FORMA ÉS FER-HO AIXÍ, AMB %, L'ALTRA SERIA ESTENENT EL HEALTHSYSTEM I FENT QUE QUAN UN REP MAL (SENYAL DAMAGE TAKEN), L'ALTRE TMB
	var ship_health_percentage : float = float($HealthSystem.health)/$HealthSystem.MAX_HEALTH*100
	var core_health_percentage : float = float($Core/HealthSystem.health)/$Core/HealthSystem.MAX_HEALTH*100
	if ship_health_percentage < core_health_percentage:
		$Core/HealthSystem.take_damage((core_health_percentage - ship_health_percentage)/100 * $Core/HealthSystem.MAX_HEALTH)
	elif core_health_percentage < ship_health_percentage:
		$HealthSystem.take_damage((ship_health_percentage - core_health_percentage)/100 * $HealthSystem.MAX_HEALTH)
	print(ship_health_percentage, "  ", core_health_percentage)
	
