extends StaticBody3D

@export var water_height: float = 0.0

func _ready():
	global_transform.origin.y = water_height
