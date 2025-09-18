extends Node3D
var card_stats
#0 - name - str
#1 - base health - int
#2 - base damage - int
#3 - description - str
#4 - ability name - str
#5 - type (bug etc.) - str
#6 - location acquired - str
#7 - rarity - str
#8 - type (support, etc.) - str
#9 - cost - int
#10 - png name - string
func _physics_process(delta: float) -> void:
	pass

func initialize(card_info):
	card_stats = card_info
	$name.text = card_info[0]
	if card_info[1] != null:
		$health_and_damage.text = str(card_info[1])+' : '+str(card_info[2])
	else:
		$health_and_damage.text = "Support"
	$cost.text = "Cost "+str(card_info[9])
	$ability_and_description.text = card_info[3]
	$card_mesh.get_surface_override_material(0).albedo_texture = load(card_info[10])
