@tool
extends Node
class_name TerrainGen

@export var mybutton: bool:
	set(value):
		generate()

var mesh : MeshInstance3D
@export var size_depth : int = 100
@export var size_width : int = 200
@export var mesh_resolution : float = 0.5
@export var gradient_scaling_factor : float = 50
@export var noise_scaling_factor : float = 50

@export var noise : FastNoiseLite

func _ready() -> void:
	generate()
	
func generate():
	for n in get_children():
		remove_child(n)
		n.queue_free() 
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size_width, size_depth)
	plane_mesh.subdivide_depth = size_depth * mesh_resolution
	plane_mesh.subdivide_width = size_width * mesh_resolution
	
	# TODO: Add material to Plane Mesh
	
	var material = StandardMaterial3D.new()
	
	
	var surface = SurfaceTool.new()
	var data = MeshDataTool.new()
	surface.create_from(plane_mesh, 0)
	
	var array_plane = surface.commit()
	data.create_from_surface(array_plane, 0)
	
	var custom_gradient = GradientTexture2D.new()
	custom_gradient.gradient = Gradient.new()
	custom_gradient.fill = 1
	custom_gradient.fill_from = Vector2(0.5, 0.5)
	custom_gradient.fill_to = Vector2(0.5, 0.1)
	var gradient_image = custom_gradient.get_image()
	gradient_image.resize(size_depth * mesh_resolution + 1, size_width * mesh_resolution + 1)
	
	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		#var linear_gradient = vertex.z + (size_depth/2)
		#var top_center = Vector2(0, size_depth/2)
		#var furthest = Vector2(size_width/2, 0)
		#var vertex_xy = Vector2(vertex.x, vertex.z)
		#var radial_gradient = clamp(remap(vertex_xy.distance_to(top_center), 0, furthest.distance_to(top_center), 0, 1), 0.25, 1)
		var y
		
		var pixel = gradient_image.get_pixel((size_depth * mesh_resolution)/2 - vertex.x, (size_width * mesh_resolution)/2 - vertex.z)
		var pixel_vector : float = remap(Vector3(pixel.r, pixel.g, pixel.b).length(), 0, 1.7, 0, 1)
		var noise_value = noise.get_noise_2d(vertex.x, vertex.z)
		
		#if pixel_vector >= 0.15:
			#pixel_vector = 1
		#else:
			#pixel_vector = 0
			
		if noise_value >= 0.15:
			noise_value = 1
		else:
			noise_value = 0
			
		pixel_vector = pixel_vector * gradient_scaling_factor
		
		if int(pixel_vector) % 10 == 0:
			pixel_vector = int(pixel_vector)
		else:
			pixel_vector = int(pixel_vector) - (int(pixel_vector) % 10)
			
		noise_value = noise_value * noise_scaling_factor
		y = pixel_vector
		

		vertex.y = y
		
		data.set_vertex(i, vertex)
		
	array_plane.clear_surfaces()
	
	data.commit_to_surface(array_plane)
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.create_from(array_plane, 0)
	surface.generate_normals()
	
	mesh = MeshInstance3D.new()
	mesh.mesh = surface.commit()
	mesh.create_trimesh_collision()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.add_to_group("NavSource")
	add_child(mesh)
	#mesh.position.z = size_depth / 2
	
func get_noise_y(x, z) -> float:
	var value = noise.get_noise_2d(x, z)
	return value
