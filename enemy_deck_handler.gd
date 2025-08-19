extends Node


class_name Enemy_Deck

@onready var hand = $enemy_hand_handler
const card_scene := preload("res://card.tscn")
@onready var card_list_gd = load("res://Scripts/Cards/CardList.gd") 
@onready var card_list = card_list_gd.complete_card_list


# type 0,1,2,3 = monster, weapon, armour, artifact

# Temp deck numbers represent indicies for compelte card list. Quick to load and find
var temp_deck = [
	0,0,1,1,2,2,3,3,4,4
]

func _ready():
	hand.connect("enemy_card_requested", _on_enemy_card_requested_signal)

func _on_enemy_card_requested_signal():
	# If there are still cards in deck, grant request and instance new card
	if temp_deck.size() != 0:
		# Instance card
		var new_card := card_scene.instantiate()
		# Connect hand to card release signal
		#hand.connect_card_released(new_card)
		# Parent card
		hand.add_child(new_card)

		# Select Random card from deck
		var random_index = randi() % temp_deck.size()
		#var card_info = temp_deck[random_index]
		var card_path = card_list[temp_deck[random_index]]
		var card_script = load(card_path).new()
		
		new_card.state = new_card.State.HAND
		new_card.player_card = true
		set_card(new_card, card_script.card_art, card_script)
		# Remove card from deck so it cant be chosen again
		temp_deck.remove_at(random_index)

	
func set_card(card, _art_path, card_script):
	# Set type and star level (All cards have these)
	card.card_type = card_script.type
	card.star_level = card_script.star
	# If a monster, set monster stats
	if card_script.type == 0:
		card.card_index = card_script.index
		card.health = card_script.health
		card.attack_score = card_script.attack_score
		card.amour_score = card_script.amour_score
		card.resist_score = card_script.resist_score
		card.attack_type = card_script.attack_type# 0 = physical, 1 = magic,2 = both, 3 = true damage
		card.attack_speed = card_script.attack_speed
		card.skill_count = card_script.skill_count
		card.refresh_ui()
		card.show_card_back()
		card.player_card = false
		
	#var card_image = card.get_node("texture")
	#card_image.texture = load(art_path)
	#card.set_stars()
