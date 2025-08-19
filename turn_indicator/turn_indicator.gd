extends Control

const card_list_gd = preload("res://Scripts/Cards/CardList.gd") 
@onready var card_list = card_list_gd.complete_card_list

@onready var attack_sequence = []
@onready var turn_controllers : Array = $icon_controller.get_children()


@rpc("any_peer")
func refresh_attack_sequence(attack_sequence_array): # Array of board_id's coming in (cards in play)
	#CLEAR ICONS?
	hide_all_icons()
	var card_nodes = get_parent().get_parent().get_card_nodes_in_play("all")
	for i in range(attack_sequence_array.size()):
		var id_to_find = attack_sequence_array[i]
		for node in card_nodes:
			
			if node.board_id == id_to_find:
				var card_path = card_list[node.card_index]
				
				var card_script = load(card_path).new()
				var icon_node : Node = turn_controllers[i].get_child(0)
				var art_path = card_script.card_icon
				
				icon_node.texture = load(art_path)
				show_icon(icon_node.get_parent())
				
		
	
func show_icon(icon_node):
	icon_node.visible = true

func hide_icon():
	for icon in turn_controllers:
		if icon.visible:
			icon.visible = false
			break
			
func hide_all_icons():
	for icon in turn_controllers:
		if icon.visible:
			icon.visible = false

	
