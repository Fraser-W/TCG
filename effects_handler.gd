extends Node

class_name Effects


@onready var target : Node

func _ready():
	pass

func damage_effect(board_id, attack_dmg):
	# Set target for both clients
	set_target(board_id)
	rpc("set_target", board_id)
	# Execute attack effect to both targets
	damage(attack_dmg)
	rpc("damage", attack_dmg)

func freeze_across(board_id): # Takes in board id of card wanting to do freeze
	var card_to_alter : Node
	var player_slots = [1,2,3,4,5]
	var enemy_slots = [5,4,3,2,1]
	var slot_number : int
	
	var cards = [] # Helper function to get nodes
	for card in get_tree().get_nodes_in_group("cards"):
		if card.board_id == board_id:
			slot_number = card.get_parent().slot_number
			break
			
	var index_to_alter = enemy_slots[player_slots.find(slot_number)]
	
	var opponent_slots = get_parent().get_parent().get_parent().get_node("OpponentField").get_node("EnemySummons").get_children()
	
	#unfreeze_across(opponent_slots)
	rpc("freeze_across_opponent", index_to_alter)
	
	for slot in opponent_slots:
		if "summon_slot_number" in slot:
			if slot.summon_slot_number == index_to_alter:
				if slot.has_node("card"):
					var card = slot.get_node("card")
					card.freeze() # TESTING ONLY ATM
					break
	
	
	

#@rpc("any_peer")
func unfreeze_across(slots):
	for slot in slots:
		if "summon_slot_number" in slot && slot.has_node("card"):
			var card = slot.get_node("card")
			card.unfreeze()


@rpc("any_peer")
func freeze_across_opponent(index_to_alter):
	var player_slots = get_parent().get_node("player_summons").get_children()

	for slot in player_slots:
		if "slot_number" in slot:
			if slot.slot_number == index_to_alter:
				if slot.has_node("card"):
					var card = slot.get_node("card")
					card.freeze() # TESTING ONLY ATM
					break
	
func transform_effect(card_id, card_script):
	var loaded_card_script = load(card_script).new()
	set_target(card_id)
	get_parent().set_card(target, loaded_card_script)
	get_parent().attack_sequence_refresh()
	rpc("transform_opponent", card_id, card_script)
	
	#refresh attack sequence
	
@rpc("any_peer")
func transform_opponent(card_id, card_script):
	var loaded_card_script = load(card_script).new()
	set_target(card_id)
	get_parent().set_card(target, loaded_card_script)
	get_parent().attack_sequence_refresh()
	
'''--------------- Effect calculations ---------------'''
@rpc("any_peer")
func damage(attack_dmg):
	var attack_calculation = attack_dmg - target.amour_score
	var current_target_health = target.health
	if attack_calculation > 0:
		target.health = current_target_health - attack_calculation
		target.refresh_ui()
		
	
@rpc("any_peer")
func heal():
	pass

@rpc("any_peer")
func add_armour():
	pass

@rpc("any_peer")
func add_resist():
	pass

@rpc("any_peer")
func add_health():
	pass

@rpc("any_peer")
func add_attack_damage():
	pass

'''--------------- SET TARGET ---------------'''
@rpc("any_peer")
func set_target(board_id):
	if board_id > 100:
		var cards = [] # Helper function to get nodes
		for card in get_tree().get_nodes_in_group("cards"):
			if card.board_id == board_id:
				target = card
				break
	else:
		if board_id == get_parent().get_node("player_hero").board_id:
			target = get_parent().get_node("player_hero")
		else:
			target = get_parent().get_parent().get_parent().get_node("OpponentField").get_node("EnemyHero")
			


	
