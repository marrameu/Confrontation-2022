extends Control

const cp_button_scene : PackedScene = preload("res://src/CommandPost/CPButton.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func update():
	for child in get_children():
		child.queue_free()
	
	for cp in get_tree().get_nodes_in_group("CommandPosts"):
		var new_button : Button = cp_button_scene.instance()
		new_button.rect_position = get_viewport().get_camera().unproject_position(cp.translation)
		new_button.rect_position -= Vector2(new_button.rect_size.x / 2, new_button.rect_size.y / 2)
		new_button.cp = cp
		new_button.connect("pressed", owner, "_on_cp_button_pressed", [cp])
		add_child(new_button)
