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
		
	rotation_degrees.z = 90.0
