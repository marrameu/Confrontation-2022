# CSG Converter + Exporter
# 2022-03-12
# Modified by lexum0
#

#This script is created by: mohammedzero43 (Xtremezero), please give credits if remixed or shared
#feel free to report bugs and suggest improvements at mohammedzero43@gmail.com
tool
extends EditorPlugin

var button_csg = Button.new()
var button_mesh = Button.new()
var object_name = ""
var obj = null

var objcont = "" #.obj content
var matcont = "" #.mat content
var fdialog: FileDialog

var selectedCombiner


func _enter_tree():
	setupButtons()
	
func _ready():
	button_csg.connect("pressed",self,"_on_csg_pressed")
	button_mesh.connect("pressed",self,"_on_mesh_pressed")
	
func _exit_tree():
	button_csg.queue_free()
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU,button_csg)
	button_mesh.queue_free()
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU,button_mesh)

func setupButtons():
	get_editor_interface().get_selection().connect("selection_changed",self,"_selectionchanged")
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU,button_csg)
	button_csg.text = "Export CSG to .obj"
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU,button_mesh)
	button_mesh.text = "Convert CSG to Mesh"
	
func _selectionchanged():
	selectedCombiner = null
	var selected = get_editor_interface().get_selection().get_selected_nodes()
	var isConversionAvailable = false

	if selected.size() == 1:
		if selected[0] is CSGCombiner:
			selectedCombiner = selected[0]
			object_name= selected[0].name
			obj = selected[0]
			isConversionAvailable = true
	
	button_csg.visible = isConversionAvailable
	button_mesh.visible = isConversionAvailable

func handles(obj):
	if obj is CSGCombiner:
		return true


func _on_csg_pressed():
	exportcsg()
func _on_mesh_pressed():
	exportcsg(true)
	
func exportcsg(convertToMesh: bool = false):
	#Variables
	objcont = "" #.obj content
	matcont = "" #.mat content
	var csgMesh= obj.get_meshes();
	var vertcount=0
	
	#OBJ Headers
	objcont+="mtllib "+object_name+".mtl\n"
	objcont+="o " + object_name + "\n";#CHANGE WITH SELECTION NAME";
	
	#Blank material
	var blank_material = SpatialMaterial.new()
	blank_material.resource_name = "BlankMaterial"
	
	var material
	var vertices
	var UVs
	
	#Get surfaces and mesh info
	for t in range(csgMesh[-1].get_surface_count()):
		var surface = csgMesh[-1].surface_get_arrays(t)
		var verts = surface[0]
		UVs = surface[4]
		var normals = surface[1]
		var mat:SpatialMaterial = csgMesh[-1].surface_get_material(t)
		var faces = []
		
		#create_faces_from_verts (Triangles)
		var tempv=0
		for v in range(verts.size()):
			if tempv%3==0:
				faces.append([])
			faces[-1].append(v+1)
			tempv+=1
			tempv= tempv%3
		
		#add verticies
		var tempvcount =0
		for ver in verts:
			objcont+=str("v ",ver[0],' ',ver[1],' ',ver[2])+"\n"
			tempvcount +=1
			
		#add UVs
		for uv in UVs:
			objcont+=str("vt ",uv[0],' ',uv[1])+"\n"
		for norm in normals:
			objcont+=str("vn ",norm[0],' ',norm[1],' ',norm[2])+"\n"
		
		#add groups and materials
		objcont+="g surface"+str(t)+"\n"
		
		if mat == null:
			mat = blank_material
		
		objcont+="usemtl "+str(mat)+"\n"
		
		#add faces
		for face in faces:
			objcont+=str("f ", face[2]+vertcount,"/",face[2]+vertcount,"/",face[2]+vertcount,
			' ',face[1]+vertcount,"/",face[1]+vertcount,"/",face[1]+vertcount,
			' ',face[0]+vertcount,"/",face[0]+vertcount,"/",face[0]+vertcount)+"\n"
		#update verts
		vertcount+=tempvcount
		
		#create Materials for current surface
		matcont+=str("newmtl "+str(mat))+'\n'
		matcont+=str("Kd ",mat.albedo_color.r," ",mat.albedo_color.g," ",mat.albedo_color.b)+'\n'
		matcont+=str("Ke ",mat.emission.r," ",mat.emission.g," ",mat.emission.b)+'\n'
		matcont+=str("d ",mat.albedo_color.a)+"\n"
		
		material = mat
		vertices = verts
	
	
	# Lx
	
	if !selectedCombiner.visible:
		print("CSGCombiner node needs to be visible")
		return
	if convertToMesh:
		# Create new mesh
		var mesh = Mesh.new()
		var color = Color(1, 1, 1)
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_material(material)
		
		for v in vertices.size():
			st.add_color(color)
			st.add_uv(UVs[v])
			st.add_vertex(vertices[v])
		
		st.generate_normals()
		st.commit(mesh)
		
		var parent = selectedCombiner.get_parent()
		var nodeName = selectedCombiner.name + " [Converted]"
		
		# get previously converted node
		var oldNode
		if parent.has_node(nodeName):
			oldNode = parent.get_node(nodeName)
		var addPhysics = false
		
		# check use collisions on combiner or previous static body
		if selectedCombiner.use_collision:
			addPhysics = true
		
		# Assign the CSG materials
		var meshMaterial = selectedCombiner.material_override
		var physicsMaterial
		if oldNode:
			if oldNode.get_child_count() > 0:
				var firstChild = oldNode.get_child(0)
				if firstChild is StaticBody:
					addPhysics = true
					physicsMaterial = firstChild.physics_material_override
			# set old node material if available or changed
			if oldNode.material_override:
				meshMaterial = oldNode.material_override
			oldNode.free()
		
		# Add Mesh Instance node with Mesh data
		var meshInstance = MeshInstance.new()
		meshInstance.mesh = mesh
		meshInstance.name = nodeName
		meshInstance.material_override = meshMaterial
		# Hide Mesh, use it only for Physics Material
#		meshInstance.visible = false
		var node = meshInstance
		parent.add_child(node)
		node.set_owner(parent)
		
		if addPhysics:
			# Create Trimesh Static Body
			meshInstance.create_trimesh_collision()
			
			# Reassign previous physics material override
			var firstChild = meshInstance.get_child(0)
			if firstChild is StaticBody:
				firstChild.name = "StaticBody"
				firstChild.physics_material_override = physicsMaterial
		
		# Log 
		var timeInfo = OS.get_time()
		var time = "%02d:%02d:%02d" % [timeInfo.hour, timeInfo.minute, timeInfo.second]
		print("[", time, "] CSGCombiner Converted")
		
		# Hide CSGCombiner
#		selectedCombiner.visible = false
		#print("CSGCombiner hidden")
		
		return
	
	#Select file destination
	fdialog = FileDialog.new()
	fdialog.mode = FileDialog.MODE_OPEN_DIR
	fdialog.access = FileDialog.ACCESS_RESOURCES
	##fdialog.add_filter("*.obj; Wavefront File")
	fdialog.show_hidden_files = false
	fdialog.window_title = "Export CSGMesh"
	fdialog.resizable = true
	
	get_editor_interface().get_editor_viewport().add_child(fdialog)
	fdialog.connect("dir_selected", self, "onFileDialogOK", [])
	# Lx
	# Retina displays
	var backingScaleFactor = OS.get_screen_scale()
	fdialog.popup_centered(Vector2(800 * backingScaleFactor, 650 * backingScaleFactor))
	
func onFileDialogOK(path: String):
	#Write to files
	var objfile = File.new()
	objfile.open(path+"/"+object_name+".obj", File.WRITE)
	objfile.store_string(objcont)
	objfile.close()

	var mtlfile = File.new()
	mtlfile.open(path+"/"+object_name+".mtl", File.WRITE)
	mtlfile.store_string(matcont)
	mtlfile.close()

	#output message
	print("CSG Mesh Exported")
	get_editor_interface().get_resource_filesystem().scan()
		