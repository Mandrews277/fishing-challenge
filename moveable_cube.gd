class_name MoveableCube extends CharacterBody3D

@export var move_speed : float = 10

func _ready():
	pass
	
func _physics_process(delta: float) -> void:
	
	handle_movement(delta)
	
func handle_movement(delta):
	var direction = Vector3.ZERO

	# Move forward (W) and backward (S)
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1

	# Move left (A) and right (D)
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	# Normalize the direction to prevent faster diagonal movement
	direction = direction.normalized()

	# Move the paddle
	velocity = direction * move_speed
	move_and_slide()
