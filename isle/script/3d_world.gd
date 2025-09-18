extends Node3D
var deck = ["Rat","Dragonfly","The Rats","Rat","Rat","Rat","Dragonfly"]
var deck_dict : Dictionary
@onready var card_list_path = "res://assets/card_list.txt"

func _ready() -> void:
	read_card_list()
	$card.initialize(["Rat",1,1,"Crazy?","N/A","Mammal","Rat Bog","Common","Creature",0,"res://assets/cards/Rat.png"])

func read_card_list():
	var file = FileAccess.open(card_list_path,FileAccess.READ)
	var text = str(file.get_as_text())
	var line = text.split("\n")
	for n in range(len(line)):
		var words = line[n].split(';')
		print(words)
		#for i in range(len(words)):
			#if words[i].is_valid_int():
				#words[i] = int(words[i])
		if words[0] in deck:
			deck_dict[words[0]] = words
	print(deck_dict)
