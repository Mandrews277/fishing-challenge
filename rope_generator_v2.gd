class_name RopeGeneratorV2 extends Node3D

@export var LINKS : int
@export var LINK_LENGTH : float
@export var LINK_WIDTH : float

var links_array : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	links_array[0] = RopeLink.instance()
	links_array[1] = RopeLink.instance()
	links_array[1].position = Vector3(0,-2,0)
	links_array[2] = RopeLink.instance()
	links_array[1].position = Vector3(0,-4,0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
