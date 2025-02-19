extends Node3D

@export var LINKS : int
@export var LINK_LENGTH : float
@export var LINK_WIDTH : float

@export var MIN_STRESS : float
@export var MAX_STRESS : float

@export var ROPE_LINK_SCENE : PackedScene  # Reference to your RopeLink.tscn scene
@export var ROPE_END : RopeEnd
@export var ROPE_TARGET : RopeTarget

var links_array : Array
var broken : bool = false
var current_max_stress : float = 0.0

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
			#var slider_joint = get_node("SliderJoint3D")
			#slider_joint.node_a = get_node("RopeStart").get_path()
			#slider_joint.node_b = rope_link_instance.get_path()
			
			var pin_joint = rope_link_instance.get_node("Joint")  # Ensure the PinJoint3D is named correctly
			pin_joint.node_a = get_node("RopeStart").get_path()
		
		links_array.append(rope_link_instance)
		
	# Add a Sphere to the end of the rope that is able to be moved
	ROPE_TARGET.position = links_array[LINKS - 1].position + links_array[LINKS - 1].LINK_END_POSITION + links_array[LINKS - 1].LINK_END_POSITION
	ROPE_END.position = links_array[LINKS - 1].position + links_array[LINKS - 1].LINK_END_POSITION
	var end_pin = ROPE_END.get_node("JoltPinJoint3D")
	end_pin.node_a = links_array[LINKS - 1].get_path()

func _physics_process(delta: float) -> void:
	var color_val : float
	for i in range(links_array.size() - 1):
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
		

		
		#DebugDraw3D.draw_arrow(current_position, next_position, Color(1, 0, 0), 0.1)
		
		DebugDraw2D.set_text("Stress", current_max_stress)
		
		if distance > current_max_stress and !broken:
			current_max_stress = distance
		
		# Clamp the distance to a value between the set min and max stress values.
		# Then remap that from 0 to 1 to set the color according to the stress.
		var clamped_distance : float = clamp(distance, MIN_STRESS, MAX_STRESS)
		color_val = remap(clamped_distance, MIN_STRESS, MAX_STRESS, 0, 1)
		current_link.get_node(found_child.get_path()).mesh.material.albedo_color = Color(color_val, 1-color_val, 0)
		
		# Break the link if the stress is ever over the set max
		if distance > MAX_STRESS and !broken:
			print("I should be trying to break a link right now")
			current_link.get_node("Joint").node_a = current_link.get_node("Joint").node_b
			broken = true
		
	var last_link = links_array[links_array.size() - 1]
	# Cycle through the final link's children to find one of type
	# MeshInstance3D. Set the color of that MeshInstance3D to green
	for child in last_link.get_children():
		if child is MeshInstance3D:
			var found_child
			found_child = child
			last_link.get_node(found_child.get_path()).mesh.material.albedo_color = Color(0, 1, 0)
			
	var direction = ROPE_END.transform.origin.direction_to(ROPE_TARGET.transform.origin)
	var distance = ROPE_END.transform.origin.distance_to(ROPE_TARGET.transform.origin)
	
	ROPE_END.TARGET_DIRECTION = direction
	ROPE_END.TARGET_DISTANCE = distance
	
func generate_rope(num_links: int) -> void:
	for i in range(num_links):
		add_link()
		
func add_link() -> void:
	# Create a new instance of the RopeLink scene
	var rope_link_instance = ROPE_LINK_SCENE.instantiate().with_data(LINK_LENGTH, LINK_WIDTH)
	
	# Add the instance to the scene tree as a child of this node
	add_child(rope_link_instance)
	
	# Set the position of the new link
	#if links_array.size() > 0:
		#var last_link = links_array[-1]
		#var pin_joint = rope_link_instance.get_node("Joint")
		#var pin_joint_last = last_link.get_node("Joint")
		#rope_link_instance.position = last_link.position + Vector3(0, -(LINK_LENGTH - (2 * LINK_WIDTH)), 0) # WILL HAVE TO UPDATE THIS LINE TO FIX LOCATION
		#
		#pin_joint.node_a = get_node("RopeStart").get_path()
		#pin_joint_last.node_a = rope_link_instance.get_path()
		#links_array.append(rope_link_instance)
	#else:
	#var slider_joint = get_node("JoltSliderJoint3D")
	
	#rope_link_instance.position = Vector3(0, -1, 0)
	#slider_joint.node_a = get_node("RopeStart").get_path()
	#slider_joint.node_b = rope_link_instance.get_path()
	links_array.append(rope_link_instance)
	#get_node("RopeEnd").position = links_array[0].LINK_END_POSITION
	#get_node("RopeEnd/JoltPinJoint3D").node_a = links_array[0].get_path()
		

func draw_debug_gizmo() -> void:
	pass
