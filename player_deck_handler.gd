extends Node

class_name Deck

@onready var hand = $hand_handler
const card_scene := preload("res://card.tscn")
@onready var card_list_gd = load("res://Scripts/Cards/CardList.gd") 
@onready var card_list = card_list_gd.complete_card_list

signal card_drawn(card)
signal set_card(card, card_script)



# Temp deck numbers represent indicies for compelte card list. Quick to load and find
var temp_deck = [
	0,0,0,2,3
]
# Will spawn all nodes into this array
@onready var deck_of_cards = []
@onready var discard_array = []
@onready var hand_array = []


func _ready():
	hand.connect("card_requested", _on_card_requested_signal)
	shuffle_deck()
	
	
	
func _on_card_requested_signal():
	if temp_deck.size() > 0:
		deck_to_hand()
		get_parent().get_parent().get_parent().get_node("OpponentField").add_card()
	
func deck_to_hand():
	var new_card := card_scene.instantiate()
	var card_index = temp_deck.pop_front()
	var card_path = card_list[card_index]
	var card_script = load(card_path).new()
	
	hand.add_child(new_card)
	new_card.hide_card_back()
	new_card.state = new_card.State.HAND
	card_drawn.emit(new_card)
	hand.connect_card_released(new_card)
	set_card_request(new_card, card_script)
	
	
func shuffle_deck():
	temp_deck.shuffle()
	
func set_card_request(card, card_script):
	set_card.emit(card, card_script)

	
func hand_to_discard(card):
	# Physical move
	card.get_parent().remove_child(card)
	$player_discard.add_child(card)
	card.position = Vector2(0,0)
	card.show_card_back()
	card.state = card.State.DISCARD
	# Array move
	hand_array.erase(card)
	discard_array.append(card)
	refresh_counters()
	
func discard_to_deck(card):
	# Physical move
	card.get_parent().remove_child(card)
	$player_deck.add_child(card)
	card.state = card.State.DECK
	
	refresh_counters()
	
func refresh_counters():
	$player_deck/deck_counter.text = str(deck_of_cards.size())
	$player_discard/discard_counter.text = str(discard_array.size())
