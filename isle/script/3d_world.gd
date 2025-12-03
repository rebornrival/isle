extends Node3D
var deck = ["Wheel of Cheese","The Unmatched Power of The Sun","Rooster","Rooster","Rooster","Hog","Hog","Cat","Rat","Wheat Stalk","Wheat Stalk","Rat","Cat","Rat"]
var deck_dict : Dictionary
var card_skew = 0
var up = 1

var enemy_gone = true
var taking_turn = false
var current_card_count : int

var enemy_attacked = true
var enemy_card_count : int

@onready var card_list_path = "res://assets/card_list.txt"
@onready var card_template = preload("res://scenes/card.tscn")

@onready var spread_curve = load("res://script/spread_curve.tres")
@onready var height_curve = load("res://script/height_curve.tres")
@onready var rotation_curve = load("res://script/rotation_curve.tres")

func _ready() -> void:
	read_card_list()
	$AnimationPlayer.play("look up")
	for i in range(5):
		var random_card = deck.pick_random()
		deck.erase(random_card)
		instantiate_card(random_card,"card_handler")
	for i in range(len(deck)):
		var random_card = deck.pick_random()
		deck.erase(random_card)
		instantiate_card(random_card,"card_board/draw_pile")

func _physics_process(delta: float) -> void:
	Globals.enemy_gone = enemy_gone
	Globals.taking_turn = taking_turn
	
	if Globals.player_health <= 0 or Globals.enemy_health <= 0:
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	
	if Input.is_action_just_pressed("look forward") and up == 0 and $AnimationPlayer.is_playing() == false:
		$AnimationPlayer.play("look up")
		up += 1
	elif Input.is_action_just_pressed("look back") and up == 1 and $AnimationPlayer.is_playing() == false:
		$AnimationPlayer.play("look down more")
		up -= 1
	elif Input.is_action_just_pressed("look forward") and up == 1 and $AnimationPlayer.is_playing() == false:
		$AnimationPlayer.play("look up more")
		up +=1 
	elif Input.is_action_just_pressed("look back") and up == 2 and $AnimationPlayer.is_playing() == false:
		$AnimationPlayer.play("look down")
		up -= 1
	
	for card in $card_handler.get_children():
		var hand_ratio = 0.5
		if $card_handler.get_child_count() > 1:
			hand_ratio = float(card.get_index())/float($card_handler.get_child_count()-1)
		
		if card.selected == true:
			Globals.selected_card_type = card.play_type
		
		if card.selected == true and Input.is_action_just_pressed("click") and Globals.slot_selected != "" and card.play_type in Globals.slot_selected and enemy_gone == true and taking_turn == false:
			card.move(get_node(Globals.slot_selected).global_position, get_node(Globals.slot_selected).rotation)
			card.velocity = (get_node(Globals.slot_selected).global_position-card.global_position).normalized()*15
			card.slot_to_go = Globals.slot_selected
			if "creature" in Globals.slot_selected:
				card.slot = Globals.slot_selected[len(Globals.slot_selected)-1]
			Globals.slot_selected = ""
			Globals.card_selected = false
			Globals.tokens -= card.cost
			$card_board.destroy_token(card.cost)
			card.selected = false
		
		if card.fired == true:
			if card.play_type == "consumable":
				card.rotation = Vector3(0,0,randf_range(-.1,.1))
			card.velocity = Vector3(0,0,0)
			$card_handler.remove_child(card)
			get_node(card.slot_to_go).add_child(card)
		
		if card.hovering == false and card.selected == false and card.in_play == false and card.dead == false and card.in_hand == true:
			if $card_handler.get_child_count()>2:
				card.position.x = spread_curve.sample(hand_ratio)*(1.5+(0.1*($card_handler.get_child_count()-7)))
			else:
				card.position.x = spread_curve.sample(hand_ratio)*0.5
			card.position.z = spread_curve.sample(hand_ratio)/30
			card.position.y = height_curve.sample(hand_ratio)
			card.rotation = Vector3(0,0,rotation_curve.sample(hand_ratio)/4)
	
	if ($turn_bell.bell_rung == true or Input.is_action_just_pressed("take_turn")) and enemy_gone == true and taking_turn == false:
		taking_turn = true
		current_card_count = 0
		$turn_bell.bell_rung = false
	
	if taking_turn == true:
		if $card_board.get_child(current_card_count).get_child_count() > 1:
			var card = $card_board.get_child(current_card_count).get_child(1)
			if card.attack_started == false:
				var card_damage = card.attack()
				if card_damage > 0:
					card.attack_time = 0.5
				else:
					card.attack_time = 0.0
				if card.slot != null and card.dead == false:
					var enemy_slot = get_node("enemy_cards/active/"+card.slot)
					if enemy_slot.get_child_count()>1:
						enemy_slot.get_child(1).take_damage(card_damage)
					else:
						Globals.enemy_health -= card_damage
					card.attack_started = true
			if card.attack_time <= 0.0:
				current_card_count += 1
				card.attack_started = false
		else: current_card_count += 1
	
	if current_card_count > 4 and taking_turn == true:
		enemy_gone = false
		taking_turn = false
		enemy_turn()
	
	if $enemy_cards.done_moving == true and enemy_gone == false:
		if $enemy_cards/active.get_child(enemy_card_count).get_child_count() > 1:
			var card = $enemy_cards/active.get_child(enemy_card_count).get_child(1)
			if card.attack_started == false:
				var card_damage = card.attack()
				if card_damage > 0:
					card.attack_time = 0.5
				else: 
					card.attack_time = 0.0
				var player_slot = get_node("card_board/creature_slot_"+str(enemy_card_count+1))
				if player_slot.get_child_count() > 1:
					player_slot.get_child(1).take_damage(card_damage)
				else:
					Globals.player_health -= card_damage
				card.attack_started = true
			if card.attack_time <= 0.0:
				enemy_card_count += 1
				card.attack_started = false
		else:
			enemy_card_count += 1
	
	if enemy_card_count > 4 and enemy_gone == false:
		enemy_gone = true
		$card_board.token_time = true

func instantiate_card(card_name,node_path):
	var card_instance = card_template.instantiate()
	get_node(node_path).add_child(card_instance)
	card_instance.initialize(deck_dict[card_name])
	if node_path == "card_board/draw_pile":
		card_instance.in_deck = true
		card_instance.rotation.z += randf_range(-.05,.05)
	else:
		card_instance.in_hand = true

func read_card_list():
	var file = FileAccess.open(card_list_path,FileAccess.READ)
	var text = str(file.get_as_text())
	var line = text.split("\n")
	for n in range(len(line)):
		var words = line[n].split(';')
		if words[0] in deck:
			deck_dict[words[0]] = words

func enemy_turn():
	$enemy_cards.move_up()
	$enemy_cards.spawned = false
	enemy_card_count = 0
