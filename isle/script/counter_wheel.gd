extends Node3D
var current_rot
var desired_rot
var spin_time 

func _process(delta: float) -> void:
	if current_rot != null and rotation_degrees.z != desired_rot and spin_time > 0.0:
		spin_time -= delta
		rotation_degrees = rotation_degrees.lerp(Vector3(0,0,desired_rot),.5)
	elif desired_rot != null:
		rotation_degrees.z = desired_rot

func spin(rotations):
	current_rot = rotation_degrees.z
	desired_rot = rotations
	spin_time = .5 * (absf(absf(current_rot) - absf(desired_rot))/36)
