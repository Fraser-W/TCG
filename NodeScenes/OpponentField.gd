extends Node2D

const card_scene := preload("res://card.tscn")
@onready var card_list_gd = load("res://Scripts/Cards/CardList.gd") 
@onready var card_list = card_list_gd.complete_card_list


@onready var opponent_hand = $EnemyHand
@onready var summon_slots = {
	5 : $EnemySummons/EnemySummon_01,
	4 : $EnemySummons/EnemySummon_02,
	3 : $EnemySummons/EnemySummon_03,
	2 : $EnemySummons/EnemySummon_04,
	1 : $EnemySummons/EnemySummon_05
}

func stand_card_down(board_id):
	# Iterate through all nodes in the 'cards' group
	for node in get_tree().get_nodes_in_group("cards"):
		if node.board_id == board_id:  # Check if the state is 'PLAY'
			node.stand_down()

func add_card():
	var card = card_scene.instantiate()
	opponent_hand.add_child(card)
	card.show_card_back()
	card.add_to_group("cards")
	

func clear_hands():
	for child in opponent_hand.get_children():
		if child.is_in_group("cards"):
			child.remove_from_group("cards")
			child.queue_free()
			
func set_monster_card(card_stats, summon_slot):
	rpc("set_opponent_monster", card_stats, summon_slot)



@rpc("any_peer")
func set_opponent_monster(card_stats, summon_slot):
	var new_card = card_scene.instantiate()
	
	new_card.card_index = card_stats["card_index"]
	new_card.board_id = card_stats["board_id"]
	new_card.card_name = card_stats["card_name"]
	new_card.card_type = card_stats["card_type"]
	new_card.card_art = card_stats["card_art"]
	new_card.card_icon = card_stats["card_icon"]
	new_card.star_level = card_stats["star_level"]
	new_card.race = card_stats["race"]
	new_card.card_class = card_stats["card_class"]
	new_card.health = card_stats["health"]
	new_card.attack_score = card_stats["attack_score"]
	new_card.amour_score = card_stats["amour_score"]
	new_card.attack_speed = card_stats["attack_speed"]
	new_card.active_skill_text = card_stats["active_skill_text"]
	new_card.passive_skill_text = card_stats["passive_skill_text"]
	new_card.card_cost = card_stats["card_cost"]
	new_card.player_card = false
	new_card.state = new_card.State.PLAY
	new_card.add_to_group("cards")

	# Set position
	summon_slots[summon_slot].add_child(new_card)
	new_card.global_position = summon_slots[summon_slot].global_position
	
	new_card.set_intial_ui()
	# Update traits
	get_parent().get_node("PlayerField").get_node("GameManager").alter_opponent_buffs()
	
func toggle_enemy_hero_is_target():
	$EnemyHero.toggle_target()
	
func remove_card_from_hand():
	# Quick hack (copy pasted clear hands). Go through enemy hand and clear 1, then break
	for child in opponent_hand.get_children():
		if child.is_in_group("cards"):
			child.remove_from_group("cards")
			child.queue_free()
		break
