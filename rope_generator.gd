class_name RopeGenerator extends MeshInstance3D

@export var isDrawing : bool
@export var POINT_COUNT : int
@export var ROPE_START : Node3D
@export var ROPE_END : Node3D
@export var ITERATIONS : int

var Points : PackedVector3Array
var Points_old : PackedVector3Array
var rope_length : float
var point_spacing : float

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func StartDrawing():
	isDrawing = true
	
func StopDrawing():
	isDrawing = false
	
func PreparePoints():
	Points.clear()
	Points_old.clear()
	
	for i in range(POINT_COUNT):
		var t = i / (POINT_COUNT - 1)
		
		Points.append(lerp(ROPE_START, ROPE_END, t))
		Points_old.append(Points[i])

func _UpdatePointSpacing():
	rope_length = (ROPE_END.global_position - ROPE_START.global_position).length()
	point_spacing = rope_length / (POINT_COUNT - 1)
	
func UpdatePoints(delta):
	Points[0] = ROPE_START.global_position
	Points[POINT_COUNT - 1] = ROPE_END.global_position
	
	_UpdatePointSpacing()
	
	for i in range(1, POINT_COUNT - 1):
		var curr : Vector3 = Points[i]
		Points[i] = Points[i] + (Points[i] - Points_old[i]) + (Vector3.DOWN * gravity * delta * delta)
		Points_old[i] = curr
		
	for i in range(ITERATIONS):
		ConstrainConnections()
		
func ConstrainConnections():
	for i in range(POINT_COUNT - 1):
		var center : Vector3 = (Points[i+1] + Points[i]) / 2.0
		var offset : Vector3 = (Points[i+1] - Points[i])
