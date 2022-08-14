extends CanvasLayer


const damage_indicator_scene : PackedScene = preload("res://src/HUD/TroopDamageIndicator.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$LifeBar.value = float(owner.get_node("HealthSystem").health) / owner.get_node("HealthSystem").MAX_HEALTH * 100


func _on_HealthSystem_damage_taken(attacker : Spatial):
	if not attacker or not weakref(attacker).get_ref():
		return
	
	for child in $"%DamageIndicators".get_children():
		if child.attacker == attacker:
			child.restart_timer()
			return
	
	var damage_indicator = damage_indicator_scene.instance()
	damage_indicator.attacker = attacker
	damage_indicator.myself = owner
	$"%DamageIndicators".add_child(damage_indicator)
