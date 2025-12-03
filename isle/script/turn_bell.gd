extends Area3D
var bell_rung = false
var hovering = false

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if hovering == true and Input.is_action_just_pressed("click"):
		bell_rung = true
		$AnimationPlayer.play("ring")

func _on_mouse_entered() -> void:
	hovering = true
	$highlight_mesh.get_surface_override_material(0).albedo_color = Color(1,1,1,0.05)

func _on_mouse_exited() -> void:
	hovering = false
	$highlight_mesh.get_surface_override_material(0).albedo_color = Color(1,1,1,0.0)
