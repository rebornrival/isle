extends Node3D
var deck = ["Rat","Rat","Rat","Hort","Rat","Glorbo"]
var deck_dict: Dictionary

@onready var card_list_path = "res://assets/card_list.txt"
@onready var card_template = preload("res://scenes/enemy_card.tscn")

func _ready() -> void:
	read_card_list()
	spawn()

func _physics_process(delta: float) -> void:
	pass

func spawn():
	var spawn_number
	var valid_slots = []
	for node in $queue.get_children():
		if node.get_child_count() == 1:
			valid_slots.append(node.name)
	if len(valid_slots) > 1:
		spawn_number = randi_range(1,2)
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
	for node in $queue.get_children():
		if node.get_child_count() > 1 and get_node("active/"+node.name).get_child_count() == 1:
			var card = node.get_child(1)
			node.remove_child(card)
			get_node("active/"+node.name).add_child(card)
			card.global_transform = card.get_parent().global_transform

func read_card_list():
	var file = FileAccess.open(card_list_path,FileAccess.READ)
	var text = str(file.get_as_text())
	var line = text.split("\n")
	for n in range(len(line)):
		var words = line[n].split(';')
		if words[0] in deck:
			deck_dict[words[0]] = words
