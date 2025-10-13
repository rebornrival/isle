extends Node3D
var deck = ["Rooster","Rooster","Rooster","Hog","Hog","Cat","Rat","Wheat Stalk","Wheat Stalk","Rat","Cat","Rat"]#["Rat","Gleebus","The Rats","Rat","Rat","Glorbo","Hort"]
var deck_dict : Dictionary
var card_skew = 0
var up = 1

var turn_time = 0.0
var enemy_gone = true

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
			Globals.selected_card_type = card.type
		
		if card.selected == true and Input.is_action_just_pressed("click") and Globals.slot_selected != "" and card.type in Globals.slot_selected:
			$card_handler.remove_child(card)
			get_node(Globals.slot_selected).add_child(card)
			if "creature" in Globals.slot_selected:
				card.slot = Globals.slot_selected[len(Globals.slot_selected)-1]
			Globals.slot_selected = ""
			Globals.card_selected = false
			Globals.tokens -= card.cost
			card.selected = false
		
		if card.hovering == false and card.selected == false and card.in_play == false:
			if $card_handler.get_child_count()>2:
				card.position.x = spread_curve.sample(hand_ratio)*(1.5+(0.1*($card_handler.get_child_count()-7)))
			else:
				card.position.x = spread_curve.sample(hand_ratio)*0.5
			card.position.z = spread_curve.sample(hand_ratio)/30
			card.position.y = height_curve.sample(hand_ratio)
			card.rotation.z = rotation_curve.sample(hand_ratio)/4
	
	if turn_time > 0:
		turn_time -= delta
	elif turn_time <=0 and enemy_gone == false:
		enemy_turn()
		enemy_gone = true
	
	if Input.is_action_just_pressed("take_turn") and enemy_gone == true:
		take_turn()
		turn_time = 1.0
		enemy_gone = false
	
	$your_health.text = "Health: " + str(Globals.player_health)
	$enemy_health.text = "Enemy health: "+str(Globals.enemy_health)
	$tokens.text = "Tokens: " +str(Globals.tokens)

func instantiate_card(card_name,node_path):
	var card_instance = card_template.instantiate()
	get_node(node_path).add_child(card_instance)
	card_instance.initialize(deck_dict[card_name])
	if node_path == "card_board/draw_pile":
		card_instance.in_deck = true
		card_instance.rotation.z += randf_range(-.05,.05)

func read_card_list():
	var file = FileAccess.open(card_list_path,FileAccess.READ)
	var text = str(file.get_as_text())
	var line = text.split("\n")
	for n in range(len(line)):
		var words = line[n].split(';')
		if words[0] in deck:
			deck_dict[words[0]] = words

func take_turn():
	for node in $card_board.get_children():
		if node.get_child_count() > 1 and "pile" not in node.name:
			var card = node.get_child(1)
			var card_damage = card.attack()
			if card.slot != null and card.dead == false:
				var enemy_slot = get_node("enemy_cards/active/"+card.slot)
				if enemy_slot.get_child_count()>1:
					enemy_slot.get_child(1).take_damage(card_damage)
				else:
					Globals.enemy_health -= card_damage

func enemy_turn():
	$enemy_cards.move_up()
	$enemy_cards.spawn()
	for node in $enemy_cards/active.get_children():
		if node.get_child_count() > 1:
			var card = node.get_child(1)
			var card_damage = card.attack()
			var player_slot = get_node("card_board/creature_slot_"+node.name)
			if player_slot.get_child_count() > 1:
				player_slot.get_child(1).take_damage(card_damage)
			else:
				Globals.player_health -= card_damage
	$card_board.token_time = true
	if Globals.tokens == 0:
		Globals.tokens += 1
