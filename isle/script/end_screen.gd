extends Node2D
func _physics_process(delta: float) -> void:
	if Globals.player_health > 0:
		$Label.text = "You Win"
	else: 
		$Label.text = "You Lose"
