extends CanvasLayer


var is_paused = false :
	get:
		return is_paused # TODOConverter40 Non existent get function 
	set(mod_value):
		is_paused = mod_value
		get_tree().paused = is_paused
		hide_default()
		$Control.visible = is_paused
		
		if is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$Control/MenuPrincipal/Reprendre.grab_focus()



# Called when the node enters the scene tree for the first time.
func _ready():
	hide_default()


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		self.is_paused = !is_paused


func _on_Reprendre_pressed():
	self.is_paused = false


func _on_Opcions_pressed():
	$Control/MenuPrincipal.hide()
	$Control/OptionsMenu.show()
	$Control/OptionsMenu/MarginContainer/VBoxContainer/TabContainer/GRAPHICS/MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer/PanelContainer/DisplayMode/DisplayMode2.grab_focus()


func _on_Sortir_pressed():
	get_tree().quit()


func hide_default():
	$Control/OptionsMenu.hide()
	$Control.hide()
	$Control/MenuPrincipal.show()


func _on_Button_pressed():
	if owner.has_node("Ships/PlayerShip") == true:
		owner.get_node("Ships/PlayerShip/HealthSystem").take_damage(INF, true)
	_on_Reprendre_pressed()
