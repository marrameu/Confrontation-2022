extends Ship
signal cp_added

const cp_scene : PackedScene = preload("res://src/CommandPost/TransportCommandPost.tscn")

var cp : Node = null


func _ready():
	if blue_team:
		$ShipMesh/Cube.material_override = blue_mat
		$ShipMesh/Cube001.material_override = blue_mat
	else:
		$ShipMesh/Cube.material_override = red_mat
		$ShipMesh/Cube001.material_override = red_mat
	connect("cp_added", get_tree().current_scene, "_on_cp_added")


func _process(delta):
	if state == States.LANDED and not weakref(cp).get_ref():
		instance_cp()
	elif state != States.LANDED and weakref(cp).get_ref():
		cp.queue_free()



func instance_cp() -> void:
	var new_cp : CommandPost = cp_scene.instance()
	new_cp.start_team = 2 if blue_team else 1
	if translation.y > 1000:
		new_cp.add_to_group("SpaceCP")
	add_child(new_cp)
	cp = new_cp
	emit_signal("cp_added")
