extends Node3D

@export var LINKS : int
@export var LINK_LENGTH : float
@export var LINK_WIDTH : float

@export var ROPE_LINK_SCENE : PackedScene  # Reference to your RopeLink.tscn scene

var links_array : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
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
			var pin_joint = rope_link_instance.get_node("Joint")  # Ensure the PinJoint3D is named correctly
			pin_joint.node_a = get_node("RopeStart").get_path()
		
		links_array.append(rope_link_instance)
		
	# Add a Sphere to the end of the rope that is able to be moved
	
	get_node("RopeEnd").position = links_array[LINKS - 1].position + links_array[LINKS - 1].LINK_END_POSITION
	get_node("RopeEnd/JoltPinJoint3D").node_a = links_array[LINKS - 1].get_path()
	
	rotation_degrees.z = 90.0
	

func _physics_process(delta: float) -> void:
	for i in range(links_array.size() - 1):
		var current_link = links_array[i]
		var next_link = links_array[i + 1]
		
		var current_position = current_link.global_transform.origin
		var next_position = next_link.global_transform.origin
		var distance = current_position.distance_to(next_position)
		
		var rest_length = LINK_LENGTH
		
		var found_child
		
		for child in current_link.get_children():
			if child is MeshInstance3D:
				found_child = child
		
		if distance > rest_length:
			# Change the material color to red to indicate stress
			current_link.get_node(found_child.get_path()).mesh.material.albedo_color = Color(1, 0, 0)
		else:
			# Change the material color to green to indicate no stress
			current_link.get_node(found_child.get_path()).mesh.material.albedo_color = Color(0, 1, 0)
			
	var found_child
	for child in links_array[links_array.size() - 1].get_children():
		if child is MeshInstance3D:
			found_child = child
	links_array[links_array.size() - 1].get_node(found_child.get_path()).mesh.material.albedo_color = Color(0, 1, 0)
