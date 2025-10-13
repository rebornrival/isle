extends Node3D
var card_stats
var health
var damage
var type
var ability_name

func _physics_process(delta: float) -> void:
	if health <= 0:
		if ability_name == "Nutritious":
			Globals.enemy_health += 1
		queue_free()
	
	if type == 'creature':
		$card_mesh/health_and_damage.text = str(damage)+' : '+str(health)
	else:
		$card_mesh/health_and_damage.text = "Support"

func attack():
	if damage != 0:
		$AnimationPlayer.play("attack")
	return damage

func take_damage(number):
	health -= number

func initialize(card_info):
	card_stats = card_info
	health = int(card_stats[1])
	damage = int(card_stats[2])
	type = card_stats[8]
	ability_name= card_stats[7]
	$card_mesh/name.text = card_info[0]
	if card_info[4] != "N/A" and card_info[3] != "N/A":
		$card_mesh/ability_and_description.text = card_info[3] + '\n' + card_info[4]
	elif card_info[3] == "N/A":
		$card_mesh/ability_and_description.text = card_info[4]
	else:
		$card_mesh/ability_and_description.text = card_info[3]
	$card_mesh.get_surface_override_material(0).albedo_texture = load(card_info[10])
