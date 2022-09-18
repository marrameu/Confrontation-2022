extends Camera3D

# var current_location_index : int = 0
var target : Node3D

@onready var original_pos := position
@onready var original_rot := rotation


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if target and weakref(target).get_ref():
		position = target.global_transform.origin
		rotation = target.global_transform.basis.get_euler()
		
		var pivot : Node3D = target.get_parent()
		pivot.rotation += Vector3((Input.get_action_strength("camera_up") - Input.get_action_strength("camera_down")), (Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left")), 0) * delta
		
		if target.owner.is_in_group("Ships"):
			var text : String
			text = target.owner.name + "\n" + target.owner.get_node("StateMachine").current_state.name + "\n" + str(target.owner.input.des_throttle) + " " + str(target.owner.input.wants_turbo) + " " + str(target.owner.input.do_turbo)
			$CanvasLayer/Label.text = text


func _on_SpawnHUD_change_spectate(location : int, index : int = 0):
	var target_ships : Array
	match location:
		0:
			target = null
			position = Vector3(1060, 1512, 2512)
			rotation_degrees = Vector3(-26.6, 11.842, 4.789)
			return
		1:
			target_ships = get_tree().get_nodes_in_group("CapitalShips")
		2:
			target_ships = get_tree().get_nodes_in_group("AttackShips")
		3:
			target_ships = get_tree().get_nodes_in_group("SupportShips")
		4:
			target_ships = get_tree().get_nodes_in_group("Ships")
	
	if target_ships:
		if index < 0:
			if index < -target_ships.size() + 1:
				index = int(abs(index))
				index %= target_ships.size()
			index = int(abs(index))
			if index != 0:
				index = target_ships.size() - index
		elif index > target_ships.size() - 1:
			index %= target_ships.size()
		target = target_ships[index].get_node("SpectateCamPivot/SpectateCamPos")
		target.get_parent().rotation = Vector3.ZERO


func _on_SpawnHUD_change_cam():
	if position == original_pos:
		position = Vector3(0, 5000, 0)
		rotation_degrees = Vector3(-90, 180, 0)
	else:
		position = original_pos
		rotation = original_rot
