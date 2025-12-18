extends RigidBody3D
var start_pos = null
var floating = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if floating == true:
		if global_position.y > -.35:
			linear_velocity = Vector3(0,0,0)
