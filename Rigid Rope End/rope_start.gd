class_name RopeStart extends RigidBody3D

@export var TARGET_SPEED: float = 1.5
@export var HAULING: bool = false
@export var CURRENT_FORCE: Vector3 = Vector3.ZERO

var _pid := Pid3D.new(0.3, 1.0, 0.7)

func _physics_process(delta: float) -> void:
	if HAULING:
		var target_velocity = Vector3(0, 1, 0) * TARGET_SPEED
		var velocity_error = target_velocity - linear_velocity
		var correction_force = _pid.update(velocity_error, delta) * 1.0
		
		#print("Current Velocity", linear_velocity)
		
		# Apply the correction force
		apply_central_force(correction_force)
