extends Node3D

#onready var asteroid = preload("res://src/Asteroid.tscn")
@onready var asteroid = preload("res://src/AsteroidFieldTest/Lod/AsteroidLod.tscn")
#onready var asteroid = preload("res://src/AsteroidFieldTest/Asteroid_Debug.tscn")

@onready var SizeEditValues = $SizeEdit.mesh.size

@export var start_roids = 1000
var max_roids = 1000000
var max_dist = 200.0

var current_roids = 1

func add_roids():
	if current_roids == max_roids:
		return
	
	var needed_roids = clamp(current_roids * 2, start_roids, max_roids)
	
	for i in range(current_roids, needed_roids):
		# Create a new mesh instance
		var new_meshinstance = asteroid
		
		#var new_meshinstance = MeshInstance3D.new()
		#new_meshinstance.mesh = $Asteroid/Meteoritlod1.mesh
		
		var s = (randf() + 0.1) * 2
		
		var r = Vector3(randf()*360, randf()*360, randf()*360)
		var t = Transform3D().scaled(Vector3(s, s, s))
		t.origin = Vector3(randf() * SizeEditValues.x, randf() * SizeEditValues.y, randf() * SizeEditValues.z) - Vector3(0.5 * SizeEditValues.x, 0.5 * SizeEditValues.y, 0.5 * SizeEditValues.z)
		
		var AsteroidInstance = new_meshinstance.instantiate()
		
		add_child(AsteroidInstance)
		AsteroidInstance.global_transform = t
		AsteroidInstance.rotation_degrees = r
	
	current_roids = needed_roids
	#$UI.text("current_roids")
	print(current_roids)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_roids()
	print(SizeEditValues)


func _process(delta):
	pass
	

