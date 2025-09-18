extends Node3D
var deck = ["Rat","Gleebus","The Rats","Rat","Rat","Rat","Glorbo","Hort"]
var deck_dict : Dictionary
var card_skew = 0
@onready var card_list_path = "res://assets/card_list.txt"
@onready var card_template = preload("res://scenes/card.tscn")

func _ready() -> void:
	read_card_list()

func _physics_process(delta: float) -> void:
	for i in range(len(deck)):
		var random_card = deck.pick_random()
		deck.erase(random_card)
		instantiate_card(random_card)
		print(deck)

func instantiate_card(card_name):
	var card_instance = card_template.instantiate()
	$card_handler.add_child(card_instance)
	card_instance.global_position = Vector3(-card_skew,0,-card_skew/2)
	card_skew+=0.25
	card_instance.initialize(deck_dict[card_name])

func read_card_list():
	var file = FileAccess.open(card_list_path,FileAccess.READ)
	var text = str(file.get_as_text())
	var line = text.split("\n")
	for n in range(len(line)):
		var words = line[n].split(';')
		if words[0] in deck:
			deck_dict[words[0]] = words
