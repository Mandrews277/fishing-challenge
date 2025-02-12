class_name RopeGenerator extends MeshInstance3D

@export var ITERATIONS : int
@export var RESOLUTION : int
@export var POINT_COUNT : int
@export var ROPE_WIDTH : float
@export var isDrawing : bool
@export var FIRST_TIME : bool
@export var ROPE_START : Node3D
@export var ROPE_END : Node3D
@export var collision_shape : CharacterBody3D

var Points : PackedVector3Array
var Points_old : PackedVector3Array
var rope_length : float
var point_spacing : float
var vertex_array : Array
var index_array : Array
var normal_array : Array
var tangent_array : Array

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PreparePoints()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	UpdatePoints(delta)
	
	GenerateMesh()

func StartDrawing():
	isDrawing = true
	
func StopDrawing():
	isDrawing = false
	
func PreparePoints():
	Points.clear()
	Points_old.clear()
	
	for i in range(POINT_COUNT):
		var t = i / (POINT_COUNT - 1)
		
		Points.append(lerp(ROPE_START.position, ROPE_END.position, t))
		Points_old.append(Points[i])

func _UpdatePointSpacing():
	rope_length = (ROPE_END.position - ROPE_START.position).length()
	point_spacing = rope_length / (POINT_COUNT - 1)
	
func UpdatePoints(delta):
	Points[0] = ROPE_START.global_position
	Points[POINT_COUNT - 1] = ROPE_END.global_position
	
	_UpdatePointSpacing()
	
	for i in range(1, POINT_COUNT - 1):
		var curr : Vector3 = Points[i]
		
		collision_shape.position = curr
		
		# Detect collisions
		for x in range(collision_shape.get_slide_collision_count()):
			var collision = collision_shape.get_slide_collision(x)
			var normal = collision.get_normal()

			# Ensure the normal is valid and not zero
			if normal.length() > 0:
				curr = curr + normal
		
		Points[i] = Points[i] + (Points[i] - Points_old[i]) + (Vector3.DOWN * gravity * delta * delta)
		Points_old[i] = curr
		
	for i in range(ITERATIONS):
		ConstrainConnections()
		
func ConstrainConnections():
	for i in range(POINT_COUNT - 1):
		var center : Vector3 = (Points[i+1] + Points[i]) / 2.0
		var offset : Vector3 = (Points[i+1] - Points[i])
		var length : float = offset.length()
		var dir : Vector3 = offset.normalized()
		
		var d = length - point_spacing
		
		if i != 0:
			# Points[i] = center + dir * d / 2.0
			Points[i] += dir * d *0.5
			
		if i+1 != POINT_COUNT - 1:
			# Points[i+1] = center - dir * d / 2.0
			Points[i+1] -= dir * d *0.5

func GenerateMesh():
	vertex_array.clear()
	
	CalculateNormals()
	
	index_array.clear()
	
	for p in range(POINT_COUNT):
		var center : Vector3 = Points[p]
		
		var forward = tangent_array[p]
		var norm = normal_array[p]
		var bitangent = norm.cross(forward).normalized()
		
		# Current Resolution
		for c in range(RESOLUTION):
			var angle = (float(c) / RESOLUTION) * 2.0 * PI
			
			var xVal = sin(angle) * ROPE_WIDTH
			var yVal = cos(angle) * ROPE_WIDTH
			
			var point = (norm * xVal) + (bitangent * yVal) + center
			vertex_array.append(point)
			
			if p < POINT_COUNT - 1:
				var start_index = RESOLUTION * p
				
				index_array.append(start_index + c);
				index_array.append(start_index + c + RESOLUTION);
				index_array.append(start_index + (c + 1) % RESOLUTION);
				
				index_array.append(start_index + (c + 1) % RESOLUTION);
				index_array.append(start_index + c + RESOLUTION);
				index_array.append(start_index + (c + 1) % RESOLUTION + RESOLUTION);
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(index_array.size() / 3):
		var p1 = vertex_array[index_array[3*i]]
		var p2 = vertex_array[index_array[3*i+1]]
		var p3 = vertex_array[index_array[3*i+2]]
		
		var tangent = Plane(p1, p2, p3)
		var normal = tangent.normal
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p1)
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p2)
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p3)
		
	mesh.surface_end()
	
func CalculateNormals():
	normal_array.clear()
	tangent_array.clear()
	
	for i in range(POINT_COUNT):
		var tangent := Vector3(0,0,0)
		var normal := Vector3(0,0,0)
		
		var temp_helper_vector := Vector3(0,0,0)
		
		# First point
		if i == 0:
			tangent = (Points[i+1] - Points[i]).normalized()
		
		# Last Point
		elif i == POINT_COUNT - 1:
			tangent = (Points[i] - Points[i-1]).normalized()
		
		# Points in Between
		else:
			tangent = (Points[i+1] - Points[i]).normalized() + (Points[i] - Points[i-1]).normalized()
			
		if i == 0:
			temp_helper_vector = -Vector3.FORWARD if (tangent.dot(Vector3.UP) > 0.5) else Vector3.UP
			
			normal = temp_helper_vector.cross(tangent).normalized()
			
			tangent_array.append(tangent)
			normal_array.append(normal)
			
		else:
			var tangent_prev = tangent_array[i-1]
			var normal_prev = normal_array[i-1]
			var bitangent = tangent_prev.cross(tangent)
			
			if bitangent.length() == 0:
				normal = normal_prev
			else:
				var bitangent_dir = bitangent.normalized()
				var theta = acos(tangent_prev.dot(tangent))
				
				var rotate_matrix = Basis(bitangent_dir, theta)
				normal = rotate_matrix * normal_prev
				
			tangent_array.append(tangent)
			normal_array.append(normal)
			
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
		
		
		
