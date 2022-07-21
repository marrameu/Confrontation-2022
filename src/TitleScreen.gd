extends Control

var loader : ResourceInteractiveLoader
var changing_scene : bool = false
var emit_signal : bool = false

signal finished_loading


func _ready() -> void:
	$MainMenu/VBoxContainer/FleetBattle.grab_focus()


func _on_SpaceStationBattle_pressed():
	show_loading_screen(false)
	load_scene("res://SpaceStationLevel.tscn", true)


func _on_FleetBattle_pressed():
	# Utilities.play_button_audio()
	# LocalMultiplayer.remap_inputs()
	show_loading_screen(false)
	load_scene("res://Level.tscn", true)


func _on_Quit_pressed() -> void:
	get_tree().quit()


func show_loading_screen(online : bool) -> void:
	$MainMenu.hide()
	$LoadingScreen.show()


func _process(delta : float) -> void:
	if changing_scene:
		if not loader:
			changing_scene = false
			return
		
		_process_load_scene()


func _process_load_scene() -> void:
	var err = loader.poll()
	if err == ERR_FILE_EOF: # Finished loading
		var resource = loader.get_resource()
		loader = null
		
		if emit_signal:
			emit_signal("finished_loading", resource)
		else:
			get_tree().change_scene_to(resource)
		
	elif err == OK:
		update_progress()
		
	else: # Error during loading
		loader = null


func load_scene(path : String, instant_load : bool) -> void:
	loader = ResourceLoader.load_interactive(path)
	emit_signal = !instant_load
	if loader == null:
		return
	changing_scene = true


func update_progress() -> void:
	var progress : float = float(loader.get_stage()) / loader.get_stage_count()
	$LoadingScreen/ProgressBar.value = progress * 100


func _on_Debug_pressed():
	show_loading_screen(false)
	load_scene("res://DebugLevel.tscn", true)
