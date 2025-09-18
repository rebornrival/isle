extends Node3D
var card_stats
var health
var damage
var cost
#0 - name - str
#1 - base health - int
#2 - base damage - int
#3 - description - str
#4 - ability description - str
#5 - type (bug etc.) - str
#6 - 2nd type (bug, etc.) - str
#7 - ability name - str
#8 - type (support, etc.) - str
#9 - cost - int
#10 - png name - string
func _physics_process(delta: float) -> void:
	pass

func initialize(card_info):
	card_stats = card_info
	health = int(card_stats[1])
	damage = int(card_stats[2])
	cost = int(card_stats[9])
	$name.text = card_info[0]
	if health != null:
		$health_and_damage.text = str(health)+' : '+str(damage)
	else:
		$health_and_damage.text = "Support"
	$cost.text = "Cost "+str(cost)
	if card_info[4] != "N/A" and card_info[3] != "N/A":
		$ability_and_description.text = card_info[3] + '\n' + card_info[4]
	elif card_info[3] == "N/A":
		$ability_and_description.text = card_info[4]
	else:
		$ability_and_description.text = card_info[3]
	$card_mesh.get_surface_override_material(0).albedo_texture = load(card_info[10])
