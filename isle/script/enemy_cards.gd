extends Node3D
var deck = ["Rat","Rat","Hog","Hog","Wheat Stalk","Cat","Rooster"]
var deck_dict = {'Rat': ['Rat', '1', '1', 'Crazy?', 'N/A', 'Mammal', 'N/A', 'N/A', 'creature', '1', 'res://assets/cards/Rat.png'], 
'The Rats': ['The Rats', '0', '0', "They prey at night, they stalk at night, they're the rats.", 'Doubles the number of rats in play.', 'N/A', 'N/A', 'The Rats', 'support', '1', 'res://assets/cards/The_Rats.png'], 
'Gleebus': ['Gleebus', '4', '1', "It's just Gleebus!", 'Summons a card from your deck to your hand.', 'G-Brothers', 'N/A', 'Draw', 'creature', '1', 'res://assets/cards/Gleebus.png'], 
'Glorbo': ['Glorbo', '1', '1', "It's Glorbo!", 'N/A', 'G-Brothers', 'N/A', 'N/A', 'creature', '0', 'res://assets/cards/Glorbo.png'], 
'Rooster': ['Rooster', '1', '0', 'That is one massive rooster.', 'N/A', 'Flying', 'N/A', 'N/A', 'creature', '0', 'res://assets/cards/Rooster.png'], 
'Hort': ['Hort', '2', '3', 'Hort...Rage', 'When near water, Hort gains 1 in each stat.', 'Mammal', 'N/A', 'Water Power', 'creature', '3', 'res://assets/cards/Hort.png'], 
'Hog': ['Hog', '1', '2', 'Brother, may I have some oats?', 'N/A', 'Mammal', 'N/A', 'N/A', 'creature', '2', 'res://assets/cards/Hog.png'], 
'Cat': ['Cat', '1', '1', 'MEOW', '+1 damage to bugs', 'Mammal', 'N/A', 'Bug Diet', 'creature', '1', 'res://assets/cards/Cat.png'], 
'Wheat Stalk': ['Wheat Stalk', '1', '0', 'a wheat sways in your hand, one last remnant from the real world.', 'When destroyed, you gain one player health.', 'Plant', 'N/A', 'Nutritious', 'creature', '1', 'res://assets/cards/Wheat_Stalk.png'], 
'Wheel of Cheese': ['Wheel of Cheese', 'N/A', 'N/A', 'Choese', 'Temporarily increase player health by 2', 'N/A', 'N/A', 'N/A', 'consumable', '1', 'res://assets/cards/Cheese.png'], 
'The Unmatched Power of The Sun': ['The Unmatched Power of The Sun', 'N/A', 'N/A', 'The dazzling rays are absorbed by the many forest creatures.', 'Increases the health of all plant cards by 2.', 'N/A', 'N/A', 'sun', 'support', '1', 'res://assets/cards/The_Unmatched_Power_of_The_Sun.png']}
var delta_var

var done_moving = true
var spawned = true

@onready var card_template = preload("res://scenes/enemy_card.tscn")

func _ready() -> void:
	spawn()

func _physics_process(delta: float) -> void:
	delta_var = delta
	
	for node in $queue.get_children():
		if node.get_child_count() > 1 and get_node("active/"+node.name).get_child_count() == 1:
			var card = node.get_child(1)
			if card.moved == true:
				node.remove_child(card)
				get_node("active/"+node.name).add_child(card)
				card.global_transform = card.get_parent().global_transform
				card.velocity = Vector3(0,0,0)
				done_moving = true
	
	if done_moving == true and spawned == false:
		spawn()
		spawned = true

func spawn():
	var spawn_number
	var number_list = [1,1,2]
	var valid_slots = []
	for node in $queue.get_children():
		if node.get_child_count() == 1:
			valid_slots.append(node.name)
	if len(valid_slots) > 1:
		spawn_number = number_list.pick_random()
	else:
		spawn_number = 1
	if len(valid_slots) > 0:
		for i in range(spawn_number):
			var random_slot = valid_slots.pick_random()
			valid_slots.erase(random_slot)
			var random_card = deck.pick_random()
			var card_instance = card_template.instantiate()
			card_instance.initialize(deck_dict[random_card])
			get_node("queue/"+random_slot).add_child(card_instance)
			card_instance.global_transform = card_instance.get_parent().global_transform

func move_up():
	done_moving = false
	var anything = 0
	for node in $queue.get_children():
		if node.get_child_count() > 1 and get_node("active/"+node.name).get_child_count() == 1:
			var card = node.get_child(1)
			card.velocity = (get_node("active/"+node.name).global_position-card.global_position).normalized()*15
			card.move_to_play(get_node("active/"+node.name).global_position)
			anything += 1
	if anything == 0:
		done_moving = true
