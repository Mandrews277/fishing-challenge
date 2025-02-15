class_name RopeLink extends RigidBody3D

var link_length: float
var link_radius : float

func _setup_rope_link() -> void:
	
	var collision_node = CollisionShape3D.new()
	add_child(collision_node)
	
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
	var material = StandardMaterial3D.new()
	mesh.material = material
	mesh_node.mesh = mesh
	mesh_node.position = Vector3(0, -((link_length / 2) - link_radius), 0)

func with_data(length : float, radius : float) -> RopeLink:
	link_length = length
	link_radius = radius
	_setup_rope_link()
	return self
