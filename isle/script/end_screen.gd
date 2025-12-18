extends Node2D
func _physics_process(delta: float) -> void:
	if Globals.player_health > 0:
		$Label.text = "You Win"
	else: 
		$Label.text = "You Lose"


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_scene.tscn")
	Globals.player_health = 15
	Globals.enemy_health = 15
	Globals.tokens = 1
	Globals.support_list = []
