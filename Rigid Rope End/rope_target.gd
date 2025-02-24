class_name RopeTarget extends RigidBody3D

@export var ROPE_END : RopeEnd
@export var TARGET_SPEED : float = 40
@export var LINK_LENGTH : float
@export var LINK : MeshInstance3D

var _pid := Pid3D.new(0.3, 0.5, 0.1)

func _ready() -> void:
	get_node("Generic6DOFJoint3D").node_b = ROPE_END.get_path()
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if global_position.y > 0.0:
		gravity_scale = 8
	elif gravity_scale > 5:
		gravity_scale = 0.25
	
	var direction : Vector3 = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down"), 
		0.0).normalized()
		
	#var target_velocity = direction * TARGET_SPEED
	#var velocity_error = target_velocity - linear_velocity
	#var correction_impulse = _pid.update(velocity_error, delta)
	apply_central_force(direction * TARGET_SPEED)
