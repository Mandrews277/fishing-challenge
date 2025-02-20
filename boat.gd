class_name Boat extends RigidBody3D

# Water Plane Reference
@export var water_plane: StaticBody3D

# Water surface height (Y-axis)
@export var water_height: float

# Fluid density (water density is typically 1000 kg/m³)
@export var fluid_density: float = 1000

# Gravity (default is 9.8 m/s²)
@export var gravity: float = 9.8

# Volume of the object (approximate)
@export var object_volume: float = 1

func _ready() -> void:
	water_height = water_plane.global_position.y

func _integrate_forces(state: PhysicsDirectBodyState3D):
	# Get the global position of the object
	var position = global_transform.origin

	# Check if the object is below the water surface
	if position.y < water_height:
		# Calculate the submerged height
		var submerged_height = water_height - position.y

		# Approximate the submerged volume (assuming a box shape)
		var submerged_volume = object_volume * (submerged_height / (2.0 * scale.y))

		# Calculate the buoyancy force
		var buoyancy_force = fluid_density * gravity * submerged_volume

		# Apply the buoyancy force upwards
		state.apply_force(Vector3.UP * buoyancy_force, Vector3.ZERO)
