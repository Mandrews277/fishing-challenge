extends RefCounted
class_name Pid3D

var _p: float
var _i: float
var _d: float

var _prev_error: Vector3 = Vector3.ZERO
var _error_integral: Vector3 = Vector3.ZERO

func _init(p: float, i: float, d: float) -> void:
	_p = p
	_i = i
	_d = d

func update(error: Vector3, delta: float) -> Vector3:
	if delta == 0:
		return Vector3.ZERO

	# Accumulate the integral term
	_error_integral += error * delta

	# Clamp the integral term to prevent windup (optional)
	_error_integral = _error_integral.limit_length(10000.0)  # Adjust the limit as needed

	# Calculate the derivative term
	var error_derivative = (error - _prev_error) / delta
	_prev_error = error

	# Calculate and return the PID output
	return _p * error + _i * _error_integral + _d * error_derivative
