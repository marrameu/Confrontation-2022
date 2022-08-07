extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$LifeBar.value = float(owner.get_node("HealthSystem").health) / owner.get_node("HealthSystem").MAX_HEALTH * 100
