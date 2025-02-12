class_name RopeLink extends RigidBody3D

@export var LINK_LENGTH : float
@export var LINK_WIDTH : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set(property: StringName, value: Variant) -> bool:
	if property == "LINK_LENGTH":
		var CollisionShape = get_tree().root.get_child(1)
		var MeshShape = get_tree().root.get_child(2)
		var Joint = get_tree().root.get_child(3)
		
		CollisionShape.Shape().Height = LINK_LENGTH
		
		return true
	elif property == "LINK_WIDTH":
		
		return true
	else:
		return false
	
