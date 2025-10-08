extends Node3D
var card_stats
var health
var damage
var cost
var type
var hovering = false
var selected = false
var current_pos
var current_height
var slot 

var in_deck = false
var in_play = false
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
	if hovering == true and in_play == false and in_deck == false:
		global_position.z = current_pos+.04
	if Input.is_action_just_pressed("click") and hovering == true and Globals.tokens >= cost and in_deck == false:
		selected = true
		Globals.card_selected = true
	elif Input.is_action_just_pressed("click"):
		selected = false
		if Globals.card_hovering == false:
			Globals.card_selected = false
	if selected == true:
		global_position.z = current_pos+.043
		global_position.y = current_height+0.125
	
	if health <= 0 and type == "creature":
		queue_free()
	
	if type == 'creature':
		$card_mesh/health_and_damage.text = str(damage)+' : '+str(health)
	else:
		$card_mesh/health_and_damage.text = "Support"

func initialize(card_info):
	card_stats = card_info
	type = card_stats[8]
	health = int(card_stats[1])
	damage = int(card_stats[2])
	cost = int(card_stats[9])
	$card_mesh/name.text = card_info[0]
	$card_mesh/cost.text = "Cost "+str(cost)
	if card_info[4] != "N/A" and card_info[3] != "N/A":
		$card_mesh/ability_and_description.text = card_info[3] + '\n' + card_info[4]
	elif card_info[3] == "N/A":
		$card_mesh/ability_and_description.text = card_info[4]
	else:
		$card_mesh/ability_and_description.text = card_info[3]
	$card_mesh.get_surface_override_material(0).albedo_texture = load(card_info[10])

func attack():
	if damage > 0:
		$AnimationPlayer.play("attack")
	return damage

func take_damage(number):
	health -= number

func _on_area_3d_mouse_entered() -> void:
	if in_play == false:
		Globals.card_hovering = true
		hovering = true
	if selected == false:
		current_pos = global_position.z
		current_height = global_position.y

func _on_area_3d_mouse_exited() -> void:
	hovering = false
	Globals.card_hovering = false
