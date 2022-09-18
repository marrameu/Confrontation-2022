extends Control

var attacker : Node3D
var myself : Node3D


func _ready():
	restart_timer()


func _on_Timer_timeout():
	queue_free()


func restart_timer():
	var tween := get_tree().create_tween()
	modulate = Color.WHITE
	tween.tween_property(self, "modulate", Color("00ffffff"), $Timer.wait_time)
	$Timer.start()
