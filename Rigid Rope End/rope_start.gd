class_name RopeStart extends RigidBody3D

@export var TARGET_SPEED: float = 1.5
@export var HAULING: bool = false
@export var CURRENT_FORCE: Vector3 = Vector3.ZERO
@export var ROPE_END: RopeEnd

var _pid := Pid3D.new(10.0, 2.0, 0.7)

func _physics_process(delta: float) -> void:
	if HAULING:
		var target_velocity = Vector3(0, 1, 0) * TARGET_SPEED
		var velocity_error
		
		if linear_velocity.length() >= TARGET_SPEED:
			apply_central_force(Vector3.ZERO)
			return  # Exit the function early
		else:
			velocity_error = target_velocity - linear_velocity
		var correction_force = _pid.update(velocity_error, delta) * 1.0
		
		# Apply the correction force
		DebugDraw2D.set_text("Corrective Force", correction_force)
		DebugDraw2D.set_text("Target Speed", target_velocity)
		DebugDraw2D.set_text("Linear Velocity", linear_velocity.length())
		apply_central_force(correction_force)
