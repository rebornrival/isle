extends Node2D
var card_stats
#0 - name - str
#1 - base health - int
#2 - base damage - int
#3 - description - str
#4 - ability name - str
#5 - type (bug etc.) - str
#6 - location acquired - str
#7 - by water? - boolean
#8 - rarity - str
#9 - type (support, etc.) - str
#10 - cost - int
func _physics_process(delta: float) -> void:
	pass

func initialize(card_info):
	card_stats = card_info
	$name.text = card_info[0]
	$health_and_damage.txt = str(card_info[1])+' : '+str(card_info[2])
	$cost.text = "Cost "+str(card_info[10])
