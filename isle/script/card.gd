extends CharacterBody3D
var card_stats
var health
var damage
var cost
var play_type
var hovering = false
var selected = false
var current_pos
var current_height
var slot 
var ability_name
var types = []

var in_deck = false
var in_play = false
var dead = false

var added = false

var sun = false

var desired_rot : Vector3
var slot_to_go = ""
var move_time := 0.0
var fired = false

var death_move_time := 0.1
var death_fired = false
var moved_to_death = false
var death_step : float

var in_hand = false
var draw_move_time := 0.1
var draw_rot : Vector3

var attack_time : float
var attack_started := false

var board = null

var tall = false
var short = false
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
	if in_play == false and dead == false and in_deck == false:
		board = get_parent().get_parent().get_node("card_board")
	
	if hovering == true and in_play == false and in_deck == false and dead == false and in_hand == true:
		global_position.z = current_pos+.04
	if Input.is_action_just_pressed("click") and hovering == true and Globals.tokens >= cost and in_deck == false and dead == false:
		selected = true
		Globals.card_selected = true
		board.hover_token(cost)
		if cost == 0:
			board.fall_token()
	elif Input.is_action_just_pressed("click") and in_deck == false and dead == false:
		selected = false
		if Globals.card_hovering == false or Globals.hover_cost > Globals.tokens:
			Globals.card_selected = false
			board.fall_token()
	if selected == true:
		global_position.z = current_pos+.043
		global_position.y = current_height+0.125
	
	if health <= 0 and play_type == "creature" and dead == false:
		if ability_name == "Nutritious":
			Globals.player_health += 1
		dead = true
	
	if in_play == true and play_type == 'support' and added == false:
		Globals.support_list.append(ability_name)
		added = true
	
	if "sun" in Globals.support_list and "Plant" in types and sun == false and in_play == true:
		health += 2
		sun = true
	
	if play_type == 'consumable' and in_play == true:
		if 'Cheese' in card_stats[0]:
			Globals.player_health += 2
		dead = true
		in_play = false
	
	if play_type == 'creature':
		$card_mesh/health_and_damage.text = str(damage)+' : '+str(health)
	elif play_type == 'support':
		$card_mesh/health_and_damage.text = "Support"
	else:
		$card_mesh/health_and_damage.text = "Consumable"
	
	if (in_play == true or play_type == "consumable") and move_time > 0.0:
		move_time -= delta
		global_rotation = global_rotation.lerp(desired_rot,(1.5)/(10))
	
	if move_time <= 0.0 and (in_play == true or (play_type == "consumable" and dead == true)) and fired == false:
		fired = true
	
	if death_move_time <= 0.0 and dead == true and death_fired == false and play_type != "consumable":
		death_fired = true
		rotation = Vector3(0,0,randf_range(-.1,.1))
	
	if dead == true and death_move_time > 0.0 and death_step != null:
		death_move_time -= delta
		rotation_degrees = rotation_degrees.lerp(Vector3(0,0,-90),(1.5)/(20))
	
	if draw_move_time > 0.0 and in_hand == false and in_deck == false:
		draw_move_time -= delta
		rotation = rotation.lerp(draw_rot,1.5/10)
	
	if draw_move_time <= 0.0 and in_hand == false:
		in_hand = true
		velocity = Vector3(0,0,0)
	
	if attack_time != null and attack_time >= 0.0:
		attack_time -= delta
	
	move_and_slide()

func initialize(card_info):
	card_stats = card_info
	play_type = card_stats[8]
	health = int(card_stats[1])
	damage = int(card_stats[2])
	cost = int(card_stats[9])
	ability_name = card_stats[7]
	types.append(card_stats[5])
	types.append(card_stats[6])
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

func move(p1,r1):
	desired_rot = r1
	move_time = global_position.distance_to(p1)/15
	in_play = true

func death_move(p1):
	death_move_time = global_position.distance_to(p1)/15
	death_step = death_move_time

func draw(starting_pos,end_rot):
	draw_move_time = global_position.distance_to(starting_pos)/18
	global_position = starting_pos
	rotation_degrees = Vector3(90,-90,0)
	draw_rot = end_rot

func _on_area_3d_mouse_entered() -> void:
	if in_play == false and dead == false:
		Globals.card_hovering = true
		Globals.hover_cost = cost
	if selected == false and hovering == false:
		hovering = true
		current_pos = global_position.z
		current_height = global_position.y
		$Area3D/CollisionShape3D.shape.size.y = 1.5

func _on_area_3d_mouse_exited() -> void:
	hovering = false
	Globals.card_hovering = false
	$Area3D/CollisionShape3D.shape.size.y = 1.4
