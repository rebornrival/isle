extends Node3D

var hovering = false
var token_time = false

var offset = 0

func _physics_process(delta: float) -> void:
	if token_time == true:
		for node in get_children():
			if node.get_child_count() > 1 and "creature" in node.name:
				Globals.tokens += 1
		token_time = false
	
	for node in get_children():
		if node.get_child_count()>1 and "pile" not in node.name:
			if node.get_child(0).get_child(0).disabled == false:
				node.get_child(1).in_play = true
				node.get_child(1).global_transform = node.global_transform
				node.get_child(0).get_child(0).disabled = true
			if node.get_child(1).dead == true:
				var card = node.get_child(1)
				node.remove_child(card)
				$discard_pile.add_child(card)
				card.rotation.z += randf_range(-.1,.1)
		elif "pile" not in node.name and node.name != "MeshInstance3D":
			node.get_child(0).get_child(0).disabled = false
	
	if $draw_pile.get_child_count() > 0:
		offset = 0
		for card in $draw_pile.get_children():
			card.position.z = offset
			offset -= .02
			if card.hovering == true and Input.is_action_just_pressed("click") and Globals.tokens > 0:
				Globals.tokens -= 1
				card.in_deck = false
				$draw_pile.remove_child(card)
				get_parent().get_node("card_handler").add_child(card)
	
	if $discard_pile.get_child_count() > 0:
		offset = 0
		for card in $discard_pile.get_children():
			card.position.z = offset
			offset += 0.02

func _on_slot_1_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_1"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature':
		$creature_slot_1/slot_1_area/c_mesh_1.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_slot_1_area_mouse_exited() -> void:
	$creature_slot_1/slot_1_area/c_mesh_1.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_slot_2_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_2"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature':
		$creature_slot_2/slot_2_area/c_mesh_2.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_slot_2_area_mouse_exited() -> void:
	$creature_slot_2/slot_2_area/c_mesh_2.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_creature_slot_3_area_3d_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_3"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature':
		$creature_slot_3/creature_slot_3_area_3d/c_mesh_3.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_creature_slot_3_area_3d_mouse_exited() -> void:
	Globals.slot_selected = ""
	$creature_slot_3/creature_slot_3_area_3d/c_mesh_3.get_surface_override_material(0).albedo_color = Color(1,1,1,0)

func _on_slot_4_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_4"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature':
		$creature_slot_4/slot_4_area/c_mesh_4.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_slot_4_area_mouse_exited() -> void:
	$creature_slot_4/slot_4_area/c_mesh_4.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_slot_5_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/creature_slot_5"
	if Globals.card_selected == true and Globals.selected_card_type == 'creature':
		$creature_slot_5/slot_5_area/c_mesh_5.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_slot_5_area_mouse_exited() -> void:
	$creature_slot_5/slot_5_area/c_mesh_5.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_support_1_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/support_slot_1"
	if Globals.card_selected == true and Globals.selected_card_type == 'support':
		$support_slot_1/support_1_area/s_mesh_1.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_support_1_area_mouse_exited() -> void:
	$support_slot_1/support_1_area/s_mesh_1.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_support_2_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/support_slot_2"
	if Globals.card_selected == true and Globals.selected_card_type == 'support':
		$support_slot_2/support_2_area/s_mesh_2.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_support_2_area_mouse_exited() -> void:
	$support_slot_2/support_2_area/s_mesh_2.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""

func _on_support_3_area_mouse_entered() -> void:
	hovering = true
	if Globals.card_selected == true: 
		Globals.slot_selected = "card_board/support_slot_3"
	if Globals.card_selected == true and Globals.selected_card_type == 'support':
		$support_slot_3/support_3_area/s_mesh_3.get_surface_override_material(0).albedo_color = Color(1,1,1,0.2)

func _on_support_3_area_mouse_exited() -> void:
	$support_slot_3/support_3_area/s_mesh_3.get_surface_override_material(0).albedo_color = Color(1,1,1,0)
	Globals.slot_selected = ""
