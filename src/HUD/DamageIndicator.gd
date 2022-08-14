extends Control

var attacker : Spatial
var myself : Spatial


func _on_Timer_timeout():
	queue_free()


func restart_timer():
	$Timer.start()
