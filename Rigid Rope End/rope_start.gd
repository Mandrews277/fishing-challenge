class_name RopeStart extends RigidBody3D

@export var TARGET_SPEED: float = 1.5
@export var HAULING: bool = false
@export var CURRENT_FORCE: Vector3 = Vector3.ZERO
@export var ROPE_END: RopeEnd

var _pid := Pid3D.new(1.0, 2.0, 0.7)

func _physics_process(delta: float) -> void:
	if HAULING:
		var target_velocity = Vector3(0, 1, 0) * TARGET_SPEED
		var velocity_error = target_velocity - Vector3(0, ROPE_END.linear_velocity.y, 0)
		var correction_force = _pid.update(velocity_error, delta) * 1.0
		
		#print("Current Velocity", linear_velocity)
		
		# Apply the correction force
		DebugDraw2D.set_text("Corrective Force", correction_force)
		DebugDraw2D.set_text("Target Speed", target_velocity)
		DebugDraw2D.set_text("Linear Velocity", ROPE_END.linear_velocity)
		apply_central_force(correction_force)
