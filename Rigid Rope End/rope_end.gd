class_name RopeEnd extends RigidBody3D

@export var TARGET_SPEED = 20
@export var TARGET_DIRECTION : Vector3
@export var TARGET_DISTANCE : float

var _pid := Pid3D.new(0.1, 0.0, 0.0)

func _physics_process(delta: float) -> void:
	DebugDraw2D.set_text("Distance To Target", TARGET_DISTANCE)
	var target_velocity = TARGET_DIRECTION * TARGET_DISTANCE * TARGET_SPEED
	var velocity_error = target_velocity - linear_velocity
	var correction_impulse = _pid.update(velocity_error, delta)
	apply_central_force(correction_impulse)
