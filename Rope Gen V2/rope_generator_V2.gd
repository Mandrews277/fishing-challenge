extends Node3D

@export var LINKS : int
@export var LINK_LENGTH : float
@export var LINK_WIDTH : float
@export var RESOLUTION : int
@export var MIN_STRESS : float
@export var MAX_STRESS : float

@export var ROPE_LINK_SCENE : PackedScene
@export var ROPE_START : RopeStart
@export var ROPE_END : RopeEnd
@export var ROPE_TARGET : RopeTarget
@export var BOAT : RigidBody3D

@export var links_array : Array
var broken : bool = false

var lengthening_toggle : bool = false
var shortening_toggle : bool = false
var physics_calc_done : bool = false

# Debug Variables
var current_max_stress : float
var last_link_pos_var

# Variables for mesh generation
var Points : PackedVector3Array
var Points_old : PackedVector3Array
var rope_length : float
var point_spacing : float
var vertex_array : Array
var index_array : Array
var normal_array : Array
var tangent_array : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#generate_rope(LINKS)
	# Check if the ROPE_LINK_SCENE is assigned
	if ROPE_LINK_SCENE == null:
		push_error("ROPE_LINK_SCENE is not assigned!")
		return
	
	for i in range(LINKS):
		# Create a new instance of the RopeLink scene
		var rope_link_instance = ROPE_LINK_SCENE.instantiate().with_data(LINK_LENGTH, LINK_WIDTH)

		# Add the instance to the scene tree as a child of this node
		add_child(rope_link_instance)
		
		# Set the position of the instance (stack them vertically)
		rope_link_instance.position = Vector3(0, -(i * (LINK_LENGTH - (2 * LINK_WIDTH))), 0)

		if i > 0:
			var previous_link = links_array[i - 1]
			var pin_joint = rope_link_instance.get_node("Joint")  # Ensure the PinJoint3D is named correctly
			pin_joint.node_a = previous_link.get_path()  # Connect to the previous link
			pin_joint.node_b = rope_link_instance.get_path()  # Connect to the current link
		else:
			# Set the position of the instance (optional)
			var slider_joint = BOAT.get_node("SliderJoint3D")
			slider_joint.node_a = ROPE_START.get_path()
			#slider_joint.node_b = rope_link_instance.get_path()
			
			var pin_joint = rope_link_instance.get_node("Joint")  # Ensure the PinJoint3D is named correctly
			pin_joint.node_a = ROPE_START.get_path()
		
		links_array.append(rope_link_instance)
		
	# Add a Sphere to the end of the rope that is able to be moved
	ROPE_TARGET.position = links_array[LINKS - 1].position + links_array[LINKS - 1].LINK_END_POSITION + links_array[LINKS - 1].LINK_END_POSITION
	ROPE_END.position = links_array[LINKS - 1].position + links_array[LINKS - 1].LINK_END_POSITION
	var end_pin = ROPE_END.get_node("JoltPinJoint3D")
	end_pin.node_a = links_array[LINKS - 1].get_path()

func _physics_process(delta: float) -> void:
	physics_calc_done = false
	draw_debug_gizmo()
	var color_val : float
	
	# Cycle through each link in the rope
	for i in range(links_array.size()-1):
		# Setup Variables to hold a reference to the current rope link
		# and the next rope link for calculating the distance between them
		var current_link = links_array[i]
		var next_link = links_array[i + 1]
		
		# Cycle through the current link's children to find one of type
		# MeshInstance3D. Store a reference to this child's name
		var found_child
		for child in current_link.get_children():
			if child is MeshInstance3D:
				found_child = child
		
		# Calculate the distance between the current and next link
		# to determine the stress on the rope at that point
		var current_position = current_link.transform.translated_local(current_link.LINK_END_POSITION).origin
		var next_position = next_link.global_transform.origin
		var distance = current_position.distance_to(next_position) * 1000
		
		# Draw Some Debug arrows and indicate the current max stress that has been put on the rope
		#DebugDraw3D.draw_arrow(current_position, next_position, Color(1, 0, 0), 0.1)
		DebugDraw2D.set_text("Stress", current_max_stress)
		
		if distance > current_max_stress and !broken:
			current_max_stress = distance
		
		# Clamp the distance to a value between the set min and max stress values.
		# Then remap that from 0 to 1 to set the color according to the stress.
		var clamped_distance : float = clamp(distance, MIN_STRESS, MAX_STRESS)
		color_val = remap(clamped_distance, MIN_STRESS, MAX_STRESS, 0, 1)
		#current_link.get_node(found_child.get_path()).mesh.material.albedo_color = Color(color_val, 1-color_val, 0)
		
		# Break the link if the stress is ever over the set max
		if distance > MAX_STRESS and !broken:
			print("I should be trying to break a link right now")
			current_link.get_node("Joint").node_a = current_link.get_node("Joint").node_b
			broken = true
			lengthening_toggle = false
			shortening_toggle = false
	
	# END OF FOR LOOP
	###############################################################################################################
	
	var last_link = links_array[links_array.size() - 1]
	var direction = ROPE_END.transform.origin.direction_to(ROPE_TARGET.transform.origin)
	var distance = ROPE_END.transform.origin.distance_to(ROPE_TARGET.transform.origin)
	var start_position = ROPE_START.position
	var start_distance = start_position.distance_to(BOAT.get_node("HaulTarget").global_position)
	
	if lengthening_toggle and distance > LINK_LENGTH * 1.1 and !broken:
		add_link(direction)
	elif shortening_toggle and start_distance < 0.25 and !broken: 
		if links_array.size() > 1:
			haul_rope()
		else:
			shortening_toggle = false
	
	ROPE_END.TARGET_DIRECTION = direction
	ROPE_END.TARGET_DISTANCE = distance
	
		# Cycle through the final link's children to find one of type
	# MeshInstance3D. Set the color of that MeshInstance3D to green
	for child in last_link.get_children():
		if child is MeshInstance3D:
			var found_child
			found_child = child
			#last_link.get_node(found_child.get_path()).mesh.material.albedo_color = Color(0, 1, 0)
			
	physics_calc_done = true
		
func add_link(direction : Vector3) -> void:
	# Create a new instance of the RopeLink scene
	var new_link_instance = ROPE_LINK_SCENE.instantiate().with_data(LINK_LENGTH, LINK_WIDTH)
	
	# Add the instance to the scene tree as a child of this node
	add_child(new_link_instance)
	
	#Set the position of the new link
	if links_array.size() > 0:
		var last_link = links_array[-1]
		
		last_link.freeze = true
		new_link_instance.freeze = true
		ROPE_END.freeze = true
		
		new_link_instance.transform = last_link.LINK_END_NODE.global_transform
		
		last_link_pos_var = last_link.position + last_link.LINK_END_POSITION
		var pin_joint = new_link_instance.get_node("Joint")
		
		pin_joint.node_a = last_link.get_path()  # Connect to the previous link
		pin_joint.node_b = new_link_instance.get_path()  # Connect to the current link
		
		last_link.freeze = false
		new_link_instance.freeze = false
		ROPE_END.freeze = false
		
		ROPE_END.position = new_link_instance.LINK_END_NODE.global_position
		var end_pin = ROPE_END.get_node("JoltPinJoint3D")
		end_pin.node_a = new_link_instance.get_path()
		
		links_array.append(new_link_instance)

func haul_rope() -> void:
	var first_link = links_array[0]
	var first_link_joint = first_link.get_node("Joint")
	var second_link = links_array[1]
	var second_link_joint = second_link.get_node("Joint")
	
	ROPE_START.freeze = true
	first_link.freeze = true
	second_link.freeze = true
	
	# Move Rope Start to the posistion of second link
	first_link_joint.node_a = first_link.get_path()
	
	ROPE_START.position = second_link.global_position
	
	second_link_joint.node_a = ROPE_START.get_path()
	
	ROPE_START.freeze = false
	first_link.freeze = false
	second_link.freeze = false
	
	var joint = BOAT.get_node("SliderJoint3D")
	joint.node_a = ROPE_START.get_path()
	
	# remove first link from array and delete node from scene
	links_array.remove_at(0)
	first_link.queue_free()
	
func draw_debug_gizmo() -> void:
	DebugDraw2D.set_text("Lengthening?", lengthening_toggle)
	DebugDraw2D.set_text("Shortening?", shortening_toggle)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("increase_rope_length"):
		if shortening_toggle or !lengthening_toggle:
			shortening_toggle = false
			ROPE_START.HAULING = false
			lengthening_toggle = true
		elif lengthening_toggle:
			ROPE_START.HAULING = false
			lengthening_toggle = false
			
	elif Input.is_action_just_pressed("decrease_rope_length"):
		if lengthening_toggle or !shortening_toggle:
			lengthening_toggle = false
			ROPE_START.HAULING = true
			shortening_toggle = true
		elif shortening_toggle:
			ROPE_START.HAULING = false
			shortening_toggle = false

func GenerateMesh():
	
	vertex_array.clear()
	index_array.clear()
	
	PreparePoints()
	CalculateNormals()
	
	var mesh = get_node("MeshInstance3D").mesh
	
	for p in range(Points.size()-1):
		var center : Vector3 = Points[p]
		
		var forward = tangent_array[p]
		var norm = normal_array[p]
		var bitangent = norm.cross(forward).normalized()
		
		# Current Resolution
		for c in range(RESOLUTION):
			var angle = (float(c) / RESOLUTION) * 2.0 * PI
			
			var xVal = sin(angle) * LINK_WIDTH
			var yVal = cos(angle) * LINK_WIDTH
			
			var point = (norm * xVal) + (bitangent * yVal) + center
			vertex_array.append(point)
			
			if p < Points.size() - 1:
				var start_index = RESOLUTION * p
			
				index_array.append(start_index + c);
				index_array.append(start_index + c + RESOLUTION);
				index_array.append(start_index + (c + 1) % RESOLUTION);
				
				index_array.append(start_index + (c + 1) % RESOLUTION);
				index_array.append(start_index + c + RESOLUTION);
				index_array.append(start_index + (c + 1) % RESOLUTION + RESOLUTION);
	
	mesh.clear_surfaces()
	
	print("Vertex Array Size:", vertex_array.size())
	print("Points Array Size:", Points.size())
	print("Links Array Size:", links_array.size())
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(Points.size()):
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
	
	for i in range(Points.size()-1):
		var tangent := Vector3(0,0,0)
		var normal := Vector3(0,0,0)
		
		var temp_helper_vector := Vector3(0,0,0)
		
		# First point
		if i == 0:
			tangent = (Points[i+1] - Points[i]).normalized()
		
		# Last Point
		elif i == links_array.size() - 1:
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
			
func PreparePoints():
	Points.clear()
	#Points_old.clear()
	
	for i in range(links_array.size()):
		Points.append(links_array[i].position)
		
	Points.append(ROPE_END.position)
