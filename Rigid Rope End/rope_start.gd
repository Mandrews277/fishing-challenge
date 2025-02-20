class_name RopeStart extends RigidBody3D

@export var TARGET_SPEED = 40
@export var HAULING : bool = false

var _pid := Pid3D.new(1.0, 0.0, 0.0)

func _physics_process(delta: float) -> void:
	if HAULING:
		var target_velocity = Vector3(0, 1, 0) * TARGET_SPEED
		var velocity_error = target_velocity - linear_velocity
		var correction_impulse = _pid.update(velocity_error, delta)
		apply_central_force(correction_impulse)
