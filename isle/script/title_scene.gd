extends Node2D
var card_game = preload("res://scenes/3d_world.tscn")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/3d_world.tscn")

func _on_esc_button_pressed() -> void:
	get_tree().quit()

func _on_instructions_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/instructions.tscn")
