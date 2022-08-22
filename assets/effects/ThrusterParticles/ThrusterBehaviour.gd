extends Spatial


var emitting = true
#onready var emission = $Fire.emitting

onready var linear_accel = $Fire.get_process_material().linear_accel
onready var damping = $Fire.get_process_material().damping
onready var radial_accel = $Fire.get_process_material().radial_accel
onready var Tangent_accel = $Fire.get_process_material().tangential_accel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func emitting_flame():
	$Fire.emitting = emitting

func normal_mode():
	linear_accel = -35.42
	damping = 0
	

func turbo_mode():
	pass
