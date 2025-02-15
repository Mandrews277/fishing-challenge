class_name RopeEnd extends RigidBody3D

const TARGET_SPEED = 20

var _pid := Pid3D.new(1.0, 0.0, 0.0)

func _physics_process(delta: float) -> void:
	var direction = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down"), 
		0.0).normalized()
	
	var target_velocity = direction * TARGET_SPEED
	var velocity_error = target_velocity - linear_velocity
	var correction_impulse = _pid.update(velocity_error, delta) * 0.01
	apply_central_impulse(correction_impulse)
	
	
	
