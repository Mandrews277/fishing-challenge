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
	
	# Create a new instance of the RopeLink scene
	var rope_link_instance = ROPE_LINK_SCENE.instantiate().with_data(1, 0.2)

	# Add the instance to the scene tree as a child of this node
	add_child(rope_link_instance)

	# Set the position of the instance (optional)
	rope_link_instance.position = Vector3(0, 0, 0)
	rope_link_instance.rotation.z = 90.0
	var pin_joint = rope_link_instance.get_node("Joint")  # Ensure the PinJoint3D is named correctly
	
	pin_joint.node_a = get_node("RopeStart").get_path()
	
