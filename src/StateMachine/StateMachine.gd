
#Base interface for a generic state machine
#It handles initializing, setting the machine active or not
#delegating _physics_process, _input calls to the State nodes,
#and changing the current/active state.

extends Node

signal state_changed(current_state)

#You must set a starting node from the inspector or checked
#the node that inherits from this state machine interface
#If you don't the game will crash (checked purpose, so you won't 
#forget to initialize the state machine)

@export var START_STATE: NodePath
var states_map = {}

var states_stack = []
var current_state = null
var active = false :
	get:
		return active # TODOConverter40 Non existent get function 
	set(value):
		active = value
		set_physics_process(value)
		set_process_input(value)
		set_process(value)
		if active:
			initialize(START_STATE)
		elif current_state:
			current_state.exit()
			states_stack = []
			current_state = null  # TODOConverter40 Copy here content of set_active

@onready var point_of_change := randf_range(1000, 1500)


func _ready():
	for child in get_children():
		child.finished.connect(_change_state)
	#set_active(true)


func initialize(start_state):
	states_stack.push_front(get_node(start_state))
	current_state = states_stack[0]
	current_state.enter()


func _input(event):
	"""
	If you make a shooter game, you may want the player to be able to
	fire bullets anytime.
	If that"s the case you don"t want to use the states. They"ll add micro
	freezes in the gameplay and/or make your code more complex
	Firing is the weapon"s responsibility (BulletSpawn here) so the code for shooting
	is all checked BulletSpawner (including input)
	"""
	current_state.handle_input(event)


func _physics_process(delta):
	if not current_state:
		return
	current_state.update(delta)


func _on_animation_finished(anim_name):
	"""
	We want to delegate every method or callback that could trigger 
	a state change to the state objects. The base script state.gd,
	that all states extend, makes sure that all states have the same
	interface, that is to say access to the same base methods, including
	_on_animation_finished. See state.gd
	"""
	if not active:
		return
	current_state._on_animation_finished(anim_name)


func _change_state(state_name):
	if not active:
		return
	current_state.exit()
	
	if state_name == "previous":
		states_stack.pop_front()
	else:
		states_stack[0] = states_map[state_name]
	
	current_state = states_stack[0]
	emit_signal("state_changed", current_state)
	
	#if state_name != "previous":
	current_state.enter()
