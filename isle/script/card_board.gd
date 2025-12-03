extends Node3D

var hovering := false
var token_time := false

@onready var rotation_curve = load("res://script/rotation_curve.tres")
@onready var spread_curve = load("res://script/spread_curve.tres")

@onready var token = preload("res://scenes/token.tscn")

var offset = 0

func _ready() -> void:
	spawn_token()

func _physics_process(delta: float) -> void:
	if token_time == true:
		var tokens_made = 0
		for node in get_children():
			if node.get_child_count() > 1 and "creature" in node.name:
				Globals.tokens += 1
				spawn_token()
				tokens_made += 1
		if tokens_made == 0:
			Globals.tokens += 1
			spawn_token()
		token_time = false
	
	for node in get_children():
		if node.get_child_count()>1 and "pile" not in node.name and "Mesh" not in node.name:
			if node.get_child(0).get_child(0).disabled == false:
				node.get_child(1).in_play = true
				node.get_child(1).global_transform = node.global_transform
				node.get_child(0).get_child(0).disabled = true
				node.get_child(0).get_child(2).visible = false
			if node.get_child(1).dead == true:
				var card = node.get_child(1)
				if card.moved_to_death == false:
					card.velocity = (($discard_pile_consumable.global_position+Vector3(0,0,($discard_pile_consumable.get_child_count()*0.02)-0.02))-card.global_position).normalized()*15
					card.death_move($discard_pile_consumable.global_position)
					card.moved_to_death = true
				if card.death_fired == true:
					card.velocity = Vector3(0,0,0)
					node.remove_child(card)
					$discard_pile_consumable.add_child(card)
				node.get_child(0).get_child(2).visible = true
		elif "pile" not in node.name and node.name != "MeshInstance3D":
			node.get_child(0).get_child(0).disabled = false
	
	if $draw_pile.get_child_count() > 0:
		offset = 0
		for card in $draw_pile.get_children():
			if card.in_deck == true:
				card.position.z = offset
				offset -= .02
			if card.hovering == true and Globals.tokens > 0:
				hover_token(1)
			else:
				if Globals.card_hovering == false and Globals.card_selected == false:
					fall_token()
			if card.hovering == true and Input.is_action_just_pressed("click") and Globals.tokens > 0:
				Globals.tokens -= 1
				get_parent().get_node("card_board").destroy_token(1)
				card.in_deck = false
				var temp_location = card.global_position
				$draw_pile.remove_child(card)
				get_parent().get_node("card_handler").add_child(card)
				var hand_ratio = 0.5
				if get_parent().get_node("card_handler").get_child_count() > 1:
					hand_ratio = float(card.get_index())/float(get_parent().get_node("card_handler").get_child_count()-1)
				if get_parent().get_node("card_handler").get_child_count()>2:
					card.velocity = ((card.global_position+Vector3(spread_curve.sample(hand_ratio)*(1.5+(0.1*(get_parent().get_node("card_handler").get_child_count()-7))),0,0)) - temp_location).normalized()*15
				else:
					card.velocity = ((card.global_position+Vector3(spread_curve.sample(hand_ratio)*0.5,0,0)) - temp_location).normalized()*15
				card.draw($draw_pile.global_position+Vector3(0,0,($draw_pile.get_child_count()-1)*0.02),Vector3(0.0,0.0,rotation_curve.sample(hand_ratio)/4))
	
	if $discard_pile_consumable.get_child_count() > 0:
		offset = 0
		$discard_pile_area/CollisionShape3D.shape.size.z = 0.224 + ($discard_pile_consumable.get_child_count()*.04)
		$discard_pile_area/MeshInstance3D.mesh.size.z = 0.224 + ($discard_pile_consumable.get_child_count()*.04)
		for card in $discard_pile_consumable.get_children():
			card.position = Vector3(0,0,offset)
			offset += 0.02
	
	if Globals.card_selected == false:
		$discard_pile_area/MeshInstance3D.get_surface_override_material(0).albedo_color = Color(1,1,1,0)

func destroy_token(n:int):
	for i in range(n):
		var token_to_kill = $MeshInstance3D/token_spawn.get_child($MeshInstance3D/token_spawn.get_child_count()-(1+i))
		token_to_kill.queue_free()

func spawn_token():
	var token_instance = token.instantiate()
	$MeshInstance3D/token_spawn.add_child(token_instance)
	token_instance.rotation_degrees = Vector3(randi_range(0,360),randi_range(0,360),randi_range(0,360))

func hover_token(n:int):
	for i in range($MeshInstance3D/token_spawn.get_child_count()-1,n-1,-1):
		var token_to_fall = $MeshInstance3D/token_spawn.get_child($MeshInstance3D/token_spawn.get_child_count()-(1+i))
		token_to_fall.gravity_scale = 1.0
		token_to_fall.start_pos = null
	for i in range(n):
		var token_to_hover = $MeshInstance3D/token_spawn.get_child($MeshInstance3D/token_spawn.get_child_count()-(1+i))
		if token_to_hover.start_pos == null:
			token_to_hover.start_pos = token_to_hover.global_position
		token_to_hover.gravity_scale = 0.0
		token_to_hover.position.y = token_to_hover.start_pos.y + 0.5
		token_to_hover.angular_velocity = Vector3(0,0,0)
		token_to_hover.linear_velocity = Vector3(0,0,0)

func fall_token():
	for single_token in $MeshInstance3D/token_spawn.get_children():
		single_token.gravity_scale = 1.0
		single_token.start_pos = null

func _on_slot_1_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_1"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$creature_slot_1/slot_1_area/c_mesh_1.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_slot_1_area_mouse_exited() -> void:
	$creature_slot_1/slot_1_area/c_mesh_1.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_slot_2_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_2"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$creature_slot_2/slot_2_area/c_mesh_2.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_slot_2_area_mouse_exited() -> void:
	$creature_slot_2/slot_2_area/c_mesh_2.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_creature_slot_3_area_3d_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_3"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$creature_slot_3/creature_slot_3_area_3d/c_mesh_3.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_creature_slot_3_area_3d_mouse_exited() -> void:
	Globals.slot_selected = ""
	$creature_slot_3/creature_slot_3_area_3d/c_mesh_3.get_surface_override_material(0).albedo_color = Color(1,1,1,0)

func _on_slot_4_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_4"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$creature_slot_4/slot_4_area/c_mesh_4.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_slot_4_area_mouse_exited() -> void:
	$creature_slot_4/slot_4_area/c_mesh_4.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_slot_5_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_5"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$creature_slot_5/slot_5_area/c_mesh_5.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_slot_5_area_mouse_exited() -> void:
	$creature_slot_5/slot_5_area/c_mesh_5.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_support_1_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/support_slot_1"
	if Globals.card_selected == true and Globals.selected_card_type == 'support' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$support_slot_1/support_1_area/s_mesh_1.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_support_1_area_mouse_exited() -> void:
	$support_slot_1/support_1_area/s_mesh_1.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_support_2_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/support_slot_2"
	if Globals.card_selected == true and Globals.selected_card_type == 'support' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$support_slot_2/support_2_area/s_mesh_2.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_support_2_area_mouse_exited() -> void:
	$support_slot_2/support_2_area/s_mesh_2.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_support_3_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/support_slot_3"
	if Globals.card_selected == true and Globals.selected_card_type == 'support' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$support_slot_3/support_3_area/s_mesh_3.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_support_3_area_mouse_exited() -> void:
	$support_slot_3/support_3_area/s_mesh_3.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_discard_pile_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true:
		Globals.slot_selected = "card_board/discard_pile_consumable"
	if Globals.card_selected == true and Globals.selected_card_type == 'consumable' and Globals.enemy_gone == true and Globals.taking_turn == false:
		$discard_pile_area/MeshInstance3D.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_discard_pile_area_mouse_exited() -> void:
	$discard_pile_area/MeshInstance3D.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ''
