extends Area3D


func _ready() -> void:
	connect("body_entered",Callable(self,"_on_body_entered"))
	connect("body_exited",Callable(self,"_on_body_exited"))


func _on_body_entered(body : CollisionObject3D) -> void:
	if body.is_in_group("Ships"):
		body.landing_areas += 1


func _on_body_exited(body : CollisionObject3D) -> void:
	if body.is_in_group("Ships"):
		body.landing_areas -= 1
