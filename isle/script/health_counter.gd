extends Node3D
var rot_list := [0,-36,-72,-108,-144,-180,-216,-252,-288,-324]
var player : int
var enemy : int

func _process(delta: float) -> void:
	if player != Globals.player_health:
		player = Globals.player_health
		if str(player).length() == 1:
			$counter_wheel4.spin(rot_list[0])
			$counter_wheel3.spin(rot_list[player])
		else:
			$counter_wheel4.spin(rot_list[int(str(player)[0])])
			$counter_wheel3.spin(rot_list[int(str(player)[1])])
	
	if enemy != Globals.enemy_health:
		enemy = Globals.enemy_health
		if str(enemy).length() == 1:
			$counter_wheel2.spin(rot_list[0])
			$counter_wheel.spin(rot_list[enemy])
		else:
			$counter_wheel2.spin(rot_list[int(str(enemy)[0])])
			$counter_wheel.spin(rot_list[int(str(enemy)[1])])
