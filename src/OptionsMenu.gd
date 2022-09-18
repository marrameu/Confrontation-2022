extends Control


#Video Settings
@onready var display_options = $MarginContainer/VBoxContainer/TabContainer/GRAPHICS/MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer/PanelContainer/DisplayMode/DisplayMode2

#Controls
@onready var SensiblitySlider = $MarginContainer/VBoxContainer/TabContainer/CONTROLS/GridContainer/SensibilitySlider

#Audio
@onready var MasterAudioSlider = $MarginContainer/VBoxContainer/TabContainer/AUDIO/GridContainer/MasterVolumSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#default sensibility
	#SensiblitySlider.value = 75
	#MasterAudioSlider.value = 0
	AudioServer.set_bus_volume_db(0, MasterAudioSlider.value)



func _process(_delta):
	$FpsNode/FPS.text = str(Engine.get_frames_per_second())
	
	"""func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		$"../MenuPrincipal".show()
		$"../MenuPrincipal/Opcions".grab_focus()
		self.hide()
	"""

func _on_SensibilitySlider_value_changed(value):
	Settings.mouse_sensitivity = value


func _on_MasterVolumSlider_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)


func _on_CheckDisplayFps_toggled(button_pressed):
	if button_pressed == true:
		$FpsNode/FPS.show()
	else:
		$FpsNode/FPS.hide()
		


func _on_CheckVsync_toggled(button_pressed):
	if button_pressed == true:
		OS.vsync_enabled = true
	else:
		OS.vsync_enabled = false


func _on_Atrs_pressed():
	$"../MenuPrincipal".show()
	self.hide()
	


func _on_OptionButton_item_selected(index):
	if index == 0:
		Settings.controller_input = false
	else:
		Settings.controller_input = true


func _on_DisplayMode2_item_selected(index):
	Settings.toggle_fullscreen(true if index == 1 else false)


func _on_BloomCheck_toggled(button_pressed):
	Settings.toggle_bloom(button_pressed)


func _on_TabContainer_tab_changed(tab):
	if tab == 0:
		$MarginContainer/VBoxContainer/TabContainer/GRAPHICS/MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer/PanelContainer/DisplayMode/DisplayMode2.grab_focus()
	elif tab == 1:
		$MarginContainer/VBoxContainer/TabContainer/AUDIO/GridContainer/MasterVolumSlider.grab_focus()
	elif tab == 2:
		$MarginContainer/VBoxContainer/TabContainer/CONTROLS/GridContainer/SensibilitySlider.grab_focus()


func _on_Button_toggled(button_pressed):
	
	if button_pressed == true:
		$MarginContainer/VBoxContainer/TabContainer/GRAPHICS/MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer/VBoxContainer.show()
	else:
		$MarginContainer/VBoxContainer/TabContainer/GRAPHICS/MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer/VBoxContainer.hide()





func _on_FXAACheck_toggled(button_pressed):
	Settings.toggle_FXAA(button_pressed)


func _on_MSAAOption_item_selected(index):
	Settings.select_MSAA(index)


func _on_HSlider_value_changed(value):
	Settings.set_sharpen_value(value)


func _on_BrightnessSlider_value_changed(value):
	Settings.set_brightness(value)


func _on_MotionBlur2_toggled(button_pressed):
	Settings.toggle_MotionBlur(button_pressed)
