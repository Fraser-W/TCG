extends Node

#var player_id = multiplayer.get_unique_id() #TEMPLATE

# Preloads
const card_scene := preload("res://card.tscn")
const hp_scene := preload("res://hp_ui.tscn")

const card_list_gd = preload("res://Scripts/Cards/CardList.gd") 
@onready var card_list = card_list_gd.complete_card_list
const all_strings_gd = preload("res://card_scripts/all_strings.gd")
const trait_buffs_gd = preload("res://trait_buffs.gd")
@onready var trait_buffs = trait_buffs_gd.new()



# Signals
signal connect_card_skills()

# Turn variables
@onready var turn_indicator = $turn_handler/turn_indicator
@onready var end_turn_button = $turn_handler/end_turn
@onready var is_player_turn : bool
@onready var is_card_phase = true
@onready var is_attack_phase = false
@onready var attack_sequence = []
@onready var attacking_card_index : int = 0
@onready var turn_counter = 0
@onready var draw_counter = 3
@onready var current_mana : int = 0
@onready var max_mana : int = 0

@onready var player_had_previous_first_turn : bool = false
@export var attack_timer : int = 10
@export var turn_timer: int = 30
@onready var card_turn_counter : int = 0


# card variables
@onready var attacking_card : Node
@onready var target : Node
@onready var skill_pressed : int
@onready var card_in_hand : bool
@onready var trait_handler = $trait_handler
@onready var cab_be_target : bool = false

# hand variables
@onready var player_hand = $player_deck_handler/hand_handler
@onready var player_deck = $player_deck_handler

@export var max_hand_size : int = 10
@onready var current_hand_card_count : int = 0

# Hero variables
@onready var player_hero = $player_hero

# Effect variables
@onready var effect_handler = $effects_handler


# Summon slot variables
@onready var player_summons = {
	1: $player_summons/player_summon_01,
	2: $player_summons/player_summon_02,
	3: $player_summons/player_summon_03,
	4: $player_summons/player_summon_04,
	5: $player_summons/player_summon_05
}


# Star level in slots
var player_summons_star_level = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}



func _input(event):
	# Debug for ending card turn
	if event.is_action_pressed("keyboard_E"):
		end_turn()
		
		
		
	if event.is_action_pressed("keyboard_F"):
		pass
		
	# TEMP!!!!!!!!!!!!!!!
	if event.is_action_pressed("esc"):
		get_tree().quit()

func _ready():
	self.add_child(trait_buffs)
	#connect to player deck signal when card is drawn
	
	if !player_deck.is_connected("card_drawn", _on_card_drawn_signal):
		player_deck.connect("card_drawn", _on_card_drawn_signal)
		player_deck.connect("set_card", _on_set_card_signal)
	trait_handler.connect("request_alter_trait_buff", _on_request_alter_trait_buff_signal)
	
	# Loop through the player_summons dictionary and connect the signals
	for key in player_summons.keys():
		var summon_node = player_summons[key]
		# Make sure the node exists and connect the signal
		if summon_node:
			summon_node.connect("card_play_check_continued", _on_card_play_check_continued_signal)
			
	
	# Connect signals
	end_turn_button.connect("end_turn_clicked", _on_end_turn_clicked_signal)
	


@rpc("any_peer")
func attack_sequence_refresh():
	attack_sequence = get_cards_in_play()
	turn_indicator.refresh_attack_sequence(attack_sequence)
	
	
	
''' ---------------------- TURNS ------------------------------- '''


func start_player_turn():
	$turn_handler/turn_indicator/turn_timer.start(turn_timer)
	end_turn_button.enable_button()
	activate_player_hand()
	is_player_turn = !is_player_turn
	card_turn_counter += 1
	
	

func start_enemy_turn():
	$turn_handler/turn_indicator/turn_timer.start(turn_timer)
	end_turn_button.disable_button()
	deactivate_player_hand()
	is_player_turn = !is_player_turn
	card_turn_counter += 1
	
	

func start_next_card_phase():
	card_turn_counter = 0
	is_card_phase = true
	turn_draw()
	begin_turn()
	
	# Mana
	max_mana += 1
	current_mana = max_mana
	$Mana/CurrentMana.text = str(current_mana)
	$Mana/MaxMana.text = "/" + str(max_mana)
	
	
func begin_turn():
	# Check if both players have played (Counted in start_player/enemy_turn)
	if card_turn_counter >= 2:
		end_card_phase()
	else:
		if is_player_turn:
			start_player_turn()
			
		else:
			start_enemy_turn()
			

func end_card_phase():
	# Switch who has previous first turn
	player_had_previous_first_turn = !player_had_previous_first_turn
	# set whos turn is it at the start of the next phase
	if player_had_previous_first_turn:
		is_player_turn = false
	else:
		is_player_turn = true
		
	'''comment out to stop slay spire style draw'''
	#clear_hands()
	
	is_card_phase = false
	# Start attack phase of cards
	start_next_attack_phase()
	
	

func start_next_attack_phase():
	deactivate_player_hand()
	
	is_attack_phase = true
	# Check for cards in play, if non, end attach phase
	if attack_sequence.size() == 0 or attacking_card_index == attack_sequence.size():
		end_attack_phase()
		
	else:
		attacking_card_index = 0
		begin_attack()
		
	

@rpc("any_peer")
func begin_attack():
	if attacking_card_index >= attack_sequence.size():
		attacking_card_index = 0
		end_attack_phase()
		
	else:
		var attacking_card_board_id
		$turn_handler/turn_indicator/turn_timer.start(attack_timer)
		attacking_card_board_id = attack_sequence[attacking_card_index]
		var card_nodes = get_card_nodes_in_play("all")
		for card in card_nodes:
			if card.board_id == attacking_card_board_id: #&& card.state == card.State.PLAY:
				attacking_card = card
			#else:
				#get_parent().get_parent().get_node("OpponentField").stand_card_down(card.board_id)
				#end_turn()
				#rpc("end_turn")
				#break
		attacking_card.ready_to_attack()
		if attacking_card.player_card:
			end_turn_button.enable_button()
		else:
			end_turn_button.disable_button()
			
	
			
	

func end_attack_phase():
	is_attack_phase = false
	start_next_card_phase()
	
	

@rpc("any_peer")
func end_turn():
	$effects_handler/darken_effect.visible = false
	if is_card_phase:
		begin_turn()
	elif is_attack_phase:
		attacking_card.stand_down()
		attacking_card_index += 1
		begin_attack()
		
		
''' ^^^^^^^^^^^^^^^^^^^^^^ TURNS ^^^^^^^^^^^^^^^^^^^^^^ '''

''' ---------------------- SIGNALS ---------------------- '''



func _on_card_dead_signal(board_id):
	var cards = get_card_nodes_in_play("all")
	for card in cards:
		if board_id == card.board_id:
			queue_free_card(card.board_id)
	
	
	
func _on_request_alter_trait_buff_signal(race_counts, class_counts):
	var player_cards = get_card_nodes_in_play("player")
	trait_buffs.alter_buffs(player_cards, race_counts, class_counts)
	rpc("set_opponent_count_dicts", race_counts, class_counts)
	
	

func _on_set_card_signal(card, card_script):
	set_card(card, card_script)	
	

	
	
	
func _on_turn_timer_timeout():
	end_turn()
	
	
func _on_end_turn_clicked_signal():
	end_turn()
	rpc("end_turn")
	
@rpc("any_peer")
func swap_enemy_cards_in_play_pos(card_id_wanting_to_move, summon_node_going_to_number):
	pass
	# Move card for opponents screen


func swap_cards_in_play_pos(card_wanting_to_move, summon_node_going_to):
	var node_from = card_wanting_to_move.get_parent()
	card_wanting_to_move.reparent(summon_node_going_to, false)
	rpc("swap_enemy_cards_in_play_pos", card_wanting_to_move.board_id, summon_node_going_to.slot_number)
	
func _on_card_play_check_continued_signal(summon_node, card):
	if card.state == card.State.PLAY:
		swap_cards_in_play_pos(card, summon_node)
		commence_passive(card.card_index, card.board_id)
		
	elif card.state == card.State.HAND:
		if card.card_cost <= current_mana:
			current_mana -= card.card_cost
			$Mana/CurrentMana.text = str(current_mana)
			if card.card_type == "Monster":
				if summon_node.is_player_summon == true:
					player_hand.remove_child(card)
							
							
					# Connect Signals on spawn
					card.connect("wanting_to_attack", _on_wanting_to_attack_signal)
					if !card.is_connected("card_dead", _on_card_dead_signal):
						card.connect("card_dead", _on_card_dead_signal)
					
					
					summon_node.add_child(card)
					connect_card_skills.emit()
					card.global_position = summon_node.global_position
					card.state = card.State.PLAY
					card.hide_playable()
					
					# Set board ID
					set_board_id(card)
					
					
					
					
					
					
					''' CARD NODE INFO TO PASS THROUGH NETWORK (Need to pass dict/array and not node)'''
					var card_stats = {
						"card_index" : card.card_index,
						"card_cost" : card.card_cost,
						"board_id" : card.board_id,
						"card_name" : card.card_name,
						"card_type" : card.card_type,
						"card_art" : card.card_art,
						"card_icon" : card.card_icon,
						"star_level" : card.star_level,
						"race" : card.race,
						"card_class" : card.card_class,
						"health" : card.health,
						"attack_score" : card.attack_score,
						"amour_score" : card.amour_score,
						"attack_speed" : card.attack_speed,
						"passive_skill_text" : card.passive_skill_text,
						"active_skill_text" : card.active_skill_text
						
						
						
					}
					# Add card to trait dispaly
					trait_handler.add_trait_to_dict(card)
					get_parent().get_parent().get_node("OpponentField").set_monster_card(card_stats, summon_node.slot_number)
					rpc("remove_opponent_card_from_hand")
					attack_sequence_refresh()
					rpc("attack_sequence_refresh")
					commence_passive(card.card_index, card.board_id)
					
			# If card is WEAPON
			if card.card_type == "Weapon":
				for child in summon_node.get_children():
					if child.is_in_group("cards"):
						if child.weapon_attached == false:
							child.set_weapon_icon(card.card_icon)
							player_hand.remove_child(card)
							card.queue_free()
							child.weapon_attached = true
							var card_path = card_list[card.card_index]
							var card_script = load(card_path).new()
							card_script.active_skill(child.board_id, effect_handler)
	
func _on_target_chosen_signal(selected_target):
	target = selected_target
	commence_skill()
	$effects_handler/darken_effect.visible = false
	remove_target_status()
	
func _on_wanting_to_attack_signal(card):
	$effects_handler/darken_effect.visible = true
	attacking_card = card
	enemies_become_targets()

func _on_card_drawn_signal(card):
	if !card.is_connected("card_picked_up", _on_card_picked_up_signal):
		card.connect("card_picked_up", _on_card_picked_up_signal)
	if !card.is_connected("card_returned_to_hand", _on_card_returned_to_hand_signal):
		card.connect("card_returned_to_hand", _on_card_returned_to_hand_signal)

# Below two signals handle when a card is picked up, other cards dont react to mouse_enter
func _on_card_picked_up_signal():
	deactivate_player_hand()

func _on_card_returned_to_hand_signal():
	activate_player_hand()
	
	

'''----------------------- HELPER FUNCTIONS ---------------------'''
@rpc("any_peer")
func game_end_win():
	var result : int = 1
	get_parent().get_parent().end_game(result)
	#rpc("game_end_loss")
	
@rpc("any_peer")
func game_end_loss():
	var result : int = 0
	get_parent().get_parent().end_game(result)
	rpc("game_end_win")
	
@rpc("any_peer")
func set_opponent_count_dicts(race_counts, class_counts):
	trait_buffs.set_opponent_counts(race_counts, class_counts)

# Now uses an opponent dictionary to track buffs
@rpc("any_peer")
func alter_opponent_buffs():
	var opponent_cards = get_card_nodes_in_play("opponent")
	trait_buffs.alter_opponent_buffs(opponent_cards)
	
@rpc("any_peer")
func remove_opponent_card_from_hand():
	get_parent().get_parent().get_node("OpponentField").remove_card_from_hand()
	
	
func set_board_id(card):
	# Set board_id
	card.board_id = randi() % 9000 + 1000
	# Check if board_id already exists, if it does, do it again
	while card.board_id in attack_sequence:
		card.board_id = randi() % 9000 + 1000
	
@rpc("any_peer")
func queue_free_card(board_id): # REMOVES CARD FROM VARIOUS THIGNS
	var cards = get_card_nodes_in_play("all")
	attack_sequence.erase(board_id)
	for card in cards:
		if card.board_id == board_id:
			card.remove_from_group("cards")
			card.queue_free()
			if card.player_card:
				trait_handler.remove_trait_from_dict(card)
				rpc("alter_opponent_buffs")
	
	
			
	#remove from group
	#remove from atk sequence
	#move to ggrave yard
	#refresh atk sequence
	#called in refresh ui when health is 0. connect when getting target

@rpc("any_peer")
func set_card(card : Node, card_script):
	
	card.card_name = card_script.card_name
	card.card_cost = card_script.card_cost
	card.card_index = card_script.index
	card.card_type = card_script.type	
	card.card_art = card_script.card_art
	card.card_icon = card_script.card_icon
	card.player_card = true
	card.active_skill_text = card_script.active_skill_text
	# If a monster, set monster stats
	if card_script.type == "Monster":
		card.race = card_script.race
		card.card_class = card_script.card_class
		card.health = card_script.health
		card.attack_score = card_script.attack_score
		card.amour_score = card_script.amour_score
		card.attack_speed = card_script.attack_speed
		card.passive_skill_text = card_script.passive_skill_text
		
	card.set_intial_ui()		

func clear_hands():
	# Remove all children from 'hand' node
	for child in player_hand.get_children():
		$player_deck_handler.hand_to_discard(child)

	get_parent().get_parent().get_node("OpponentField").clear_hands()
	

func activate_player_hand():
	var cards = player_hand.get_children()
	for card in cards:
		if card.is_in_group("cards"):
			card.can_be_played = true
			card.show_playable()
	
			
func deactivate_player_hand():
	var cards = player_hand.get_children()
	for card in cards:
		if card.is_in_group("cards"):
			card.can_be_played = false
			card.hide_playable()
	

func commence_skill():
	var card_path = card_list[attacking_card.card_index]
	var card_script = load(card_path).new()
	card_script.active_skill(target.board_id, effect_handler)
	get_parent().get_parent().get_node("OpponentField").stand_card_down(attacking_card.board_id)
	end_turn()
	rpc("end_turn")
		
func commence_passive(card_index, board_id):
	var card_path = card_list[card_index]
	var card_script = load(card_path).new()
	card_script.passive_skill(effect_handler, board_id)
	
func draw_card():
	player_hand.add_card()
	#get_parent().get_parent().get_node("OpponentField").add_card()
	current_hand_card_count += 1
	
func turn_draw():
	if current_hand_card_count < max_hand_size:
		draw_card()
		
	
	
	'''SLAY SPIRE TYPE DRAW'''
	#for i in range(draw_counter):
		#player_hand.add_card()
		#get_parent().get_parent().get_node("OpponentField").add_card()
		## CONNECT TARGET CHOSEN TO OLD CARDS
	#if draw_counter < max_hand_size:
		#draw_counter += 1
	turn_counter += 1

func get_cards_in_play():
	var cards = []
	var board_ids = []
	# Iterate through all nodes in the 'cards' group
	for node in get_tree().get_nodes_in_group("cards"):
		if node is Card:
			if node.state == node.State.PLAY:  # Check if the state is 'PLAY'
				cards.append(node)
	cards.sort_custom(func(a, b):
		return b.attack_speed - a.attack_speed
	)
	for card in cards:
		board_ids.append(card.board_id)
	return board_ids
	
func get_card_nodes_in_play(selected_cards : String):
	
	var all_cards = []
	var player_cards = []
	var opponent_cards = []
	# Iterate through all nodes in the 'cards' group
	for card in get_tree().get_nodes_in_group("cards"):
		if card.state == card.State.PLAY:  # Check if the state is 'PLAY'
			all_cards.append(card)
			if card.player_card:
				player_cards.append(card)
			else:
				opponent_cards.append(card)

				
				
	# Sort arrays
	all_cards.sort_custom(func(a, b):
		return a.attack_speed - b.attack_speed
	)
	player_cards.sort_custom(func(a, b):
		return a.attack_speed - b.attack_speed
	)
	opponent_cards.sort_custom(func(a, b):
		return a.attack_speed - b.attack_speed
	)
	if selected_cards == "all":
		return all_cards
	elif selected_cards == "player":
		return player_cards
	elif selected_cards == "opponent":
		return opponent_cards

func get_current_cards() -> Array:
	var cards = []
	# Iterate through all nodes in the scene tree starting from the root
	# and look through 'cards' group
	for node in get_tree().get_nodes_in_group("cards"): 
		if node.is_in_group("cards"):
			cards.append(node)
	
	return cards

func enemies_become_targets():
	var enemy_hero = get_parent().get_parent().get_node("OpponentField").get_node("EnemyHero")
	var current_cards = get_current_cards()
	for card in current_cards:
		if !card.is_connected("target_chosen", _on_target_chosen_signal):
			card.connect("target_chosen", _on_target_chosen_signal)
			
		if !card.is_connected("card_dead", _on_card_dead_signal):
			card.connect("card_dead", _on_card_dead_signal)
			
		card.is_target = true
	if !enemy_hero.is_connected("target_chosen", _on_target_chosen_signal):
		enemy_hero.connect("target_chosen", _on_target_chosen_signal)
	get_parent().get_parent().get_node("OpponentField").toggle_enemy_hero_is_target()
	
	
func allies_become_targets():
	var current_cards = get_current_cards()
	for card in current_cards:
		if !card.is_connected("target_chosen", _on_target_chosen_signal):
			card.connect("target_chosen", _on_target_chosen_signal)
			
		if !card.is_connected("card_dead", _on_card_dead_signal):
			card.connect("card_dead", _on_card_dead_signal)
			
		card.is_target = true
	
func all_become_targets():
	var current_cards = get_current_cards()
	for card in current_cards:
		if !card.is_connected("target_chosen", _on_target_chosen_signal):
			card.connect("target_chosen", _on_target_chosen_signal)
			
		if !card.is_connected("card_dead", _on_card_dead_signal):
			card.connect("card_dead", _on_card_dead_signal)
			
		card.is_target = true
		
	
func remove_target_status():
	var enemy_hero = get_parent().get_parent().get_node("OpponentField").get_node("EnemyHero")
	var current_cards = get_current_cards()
	for card in current_cards:
		if card.is_connected("target_chosen", _on_target_chosen_signal):
			card.disconnect("target_chosen", _on_target_chosen_signal)
			
		card.is_target = false
	if enemy_hero.is_connected("target_chosen", _on_target_chosen_signal):
		enemy_hero.disconnect("target_chosen", _on_target_chosen_signal)
	get_parent().get_parent().get_node("OpponentField").toggle_enemy_hero_is_target()
	
	
# Host sets board_id for heros
func host_hero_id_setup():
	$player_hero.board_id = 11
	get_parent().get_parent().get_node("OpponentField").get_node("EnemyHero").board_id = 22
	
# Person joining sets the reverse order for ID's to mirror host
func client_hero_id_setup():
	$player_hero.board_id = 22
	get_parent().get_parent().get_node("OpponentField").get_node("EnemyHero").board_id = 11


	
