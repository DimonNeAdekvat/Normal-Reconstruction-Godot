extends Node3D
@export_range(0,1) var split = 0.5 : set = set_split

@onready var mesh_R : ArrayMesh = $ShaderPlaneR.mesh
@onready var mesh_L : ArrayMesh = $ShaderPlaneL.mesh

func _ready():
	var shift = split * 2.0 - 1.0
	var verts_R = PackedVector3Array()
	verts_R.append(Vector3(shift, -1.0, 0.0))
	verts_R.append(Vector3(3.0, -1.0, 0.0))
	verts_R.append(Vector3(shift, 3.0, 0.0))
	var mesh_array_R = []
	mesh_array_R.resize(Mesh.ARRAY_MAX)
	mesh_array_R[Mesh.ARRAY_VERTEX] = verts_R
	mesh_R.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array_R)
	
	var verts_L = PackedVector3Array()
	verts_L.append(Vector3(shift, -1.0, 0.0))
	verts_L.append(Vector3(shift, 3.0, 0.0))
	verts_L.append(Vector3(-3.0, -1.0, 0.0))
	var mesh_array_L = []
	mesh_array_L.resize(Mesh.ARRAY_MAX)
	mesh_array_L[Mesh.ARRAY_VERTEX] = verts_L
	mesh_L.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array_L)


func set_split(split_new: float):
	split = split_new
	if !is_inside_tree():
		return
	var shift = split * 2.0 - 1.0
	var verts_R = PackedVector3Array()
	verts_R.append(Vector3(shift, -1.0, 0.0))
	verts_R.append(Vector3(3.0, -1.0, 0.0))
	verts_R.append(Vector3(shift, 3.0, 0.0))
	mesh_R.surface_update_vertex_region(0,0,verts_R.to_byte_array())
	var verts_L = PackedVector3Array()
	verts_L.append(Vector3(shift, -1.0, 0.0))
	verts_L.append(Vector3(shift, 3.0, 0.0))
	verts_L.append(Vector3(-3.0, -1.0, 0.0))
	mesh_L.surface_update_vertex_region(0,0,verts_L.to_byte_array())
	
	
