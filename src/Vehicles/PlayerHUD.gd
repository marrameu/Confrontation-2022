extends CanvasLayer


onready var cursor_original_pos : Vector2 = $Cursor.rect_position


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if owner.active:
		$Cursor.rect_position = cursor_original_pos + Vector2(owner.input.pitch, owner.input.yaw).clamped(200) # el màxim és 250, però posem una mica menys a la interfcíie pq si no hi hauria alguns tirons amb el lerp
		
		# print(owner.input.pitch, "  ", owner.input.yaw)
