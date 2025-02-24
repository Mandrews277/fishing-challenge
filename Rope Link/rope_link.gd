class_name RopeLink extends RigidBody3D

@export var LINK_END_POSITION : Vector3
@export var LINK_END_NODE : Node3D

var link_length: float
var link_radius : float
var collision_shape : CollisionShape3D

func _setup_rope_link() -> void:
	
	freeze_mode = FREEZE_MODE_STATIC
	
	var collision_node = CollisionShape3D.new()
	add_child(collision_node)
	
	collision_shape = collision_node
	
	var shape = CapsuleShape3D.new()
	shape.height = link_length
	shape.radius = link_radius
	collision_node.shape = shape
	collision_node.position = Vector3(0, -((link_length / 2) - link_radius), 0)
	
	var mesh_node = MeshInstance3D.new()
	add_child(mesh_node)
	var mesh = CapsuleMesh.new()
	mesh.radius = link_radius
	mesh.height = link_length
	mesh.rings = 1
	mesh.radial_segments = 5
	mesh_node.mesh = mesh
	mesh_node.position = Vector3(0, -((link_length / 2) - link_radius), 0)
	
	LINK_END_POSITION = Vector3(0, -1, 0) * (link_length - (2 * link_radius))
	
	var link_end : Node3D = Node3D.new()
	add_child(link_end)
	link_end.position = Vector3(0, -1, 0) * (link_length - (2 * link_radius))
	LINK_END_NODE = link_end

func with_data(length : float, radius : float) -> RopeLink:
	link_length = length
	link_radius = radius
	_setup_rope_link()
	return self
	
func disable_collision() -> void:
	collision_shape.disabled = true
	print(collision_shape.disabled)
	
func enable_collision() -> void:
	collision_shape.disabled = false
	print(collision_shape.disabled)
