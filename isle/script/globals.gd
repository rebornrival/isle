extends Node
var card_selected = false
var card_hovering = false
var slot_selected = ""
var selected_card_type

var player_health = 15
var enemy_health = 15
var tokens = 1

var support_list = []

var enemy_gone : bool
var taking_turn : bool

var hover_cost : int
