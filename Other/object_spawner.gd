extends Node3D

@export var LINKS : int
@export var LINK_LENGTH : float
@export var LINK_WIDTH : float

var links_array : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create a RigidBody3D
	var rigid_body = RigidBody3D.new()

	# Set mass (optional)
	rigid_body.mass = 1.0

	# Set gravity scale (optional)
	rigid_body.gravity_scale = 1.0

	# Add a CollisionShape3D (required for physics)
	var collision_shape = CollisionShape3D.new()
	rigid_body.add_child(collision_shape)

	# Set the shape of the collision shape (e.g., a box)
	var shape = BoxShape3D.new()
	shape.size = Vector3(1, 1, 1)
	collision_shape.shape = shape

	# Add a MeshInstance3D to make the RigidBody3D visible
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()  # Use a BoxMesh for simplicity
	box_mesh.size = Vector3(1, 1, 1)  # Match the mesh size to the collision shape
	mesh_instance.mesh = box_mesh

	# Add the MeshInstance3D as a child of the RigidBody3D
	rigid_body.add_child(mesh_instance)

	# Add the RigidBody3D to the scene tree as a child of this node
	add_child(rigid_body)

	# Set the position of the rigid body relative to its parent
	rigid_body.position = Vector3(0, 0, 0)
