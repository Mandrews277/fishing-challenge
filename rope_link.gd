class_name RopeLink extends RigidBody3D

var link_length: float
var link_radius : float

func _init() -> void:
	
	var collision_node = CollisionShape3D.new()
	add_child(collision_node)
	
	var shape = CapsuleShape3D.new()
	shape.height = link_length
	shape.radius = link_radius
	shape.position = Vector3(0, -((link_length / 2) - link_radius), 0)
	
	collision_node.shape = shape
	
	var mesh_node = MeshInstance3D.new()
	
	var mesh = CapsuleMesh.new()
	
	mesh.radius = link_radius
	mesh.height = link_length
	mesh.position = Vector3(0, -((link_length / 2) - link_radius), 0)
	
	mesh_node.mesh = mesh

func with_data(length : float, radius : float) -> RopeLink:
	link_length = length
	link_radius = radius
	return self
