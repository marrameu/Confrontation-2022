extends WorldEnvironment


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.connect("bloom_toggled", self, "_on_bloom_toggled")
	Settings.connect("set_brightness", self, "_on_set_brightness")


func _on_bloom_toggled(value):
	environment.glow_enabled = value
	print ("bloom desactivado")


func _on_set_brightness(value):
	environment.adjustment_brightness = value
