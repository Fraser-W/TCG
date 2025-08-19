extends Node

'''
PRE-LOADS
'''
#const all_strings_gd = preload("res://card_scripts/all_strings.gd") 
const trait_display := preload("res://trait_display.tscn")
const trait_buffs_gd := preload("res://trait_buffs.gd")

'''
SIGNALS
'''
signal request_alter_trait_buff(race_counts, class_counts)




'''
VARIABLES
'''

@onready var trait_box = $trait_box
@onready var race_counts = {}
@onready var class_counts = {}
@onready var trait_ref = {}
@onready var current_display_selected : Node

'''
UI HANDLING
'''
#func refresh_buffs(cards):
	#for card in cards:
		#update_display(trait_name_ref, count)

func add_trait_to_dict(card): 
	# If race count and display exists, add and update
	if card.race in race_counts:
		race_counts[card.race] += 1
		update_display(card.race, race_counts[card.race])
	# If count and display DOESN'T exist, add to count and spawn display
	else:
		race_counts[card.race] = 1
		spawn_trait_display(card.race)
	
	
	# Same setup for class count
	if card.card_class in class_counts:
		class_counts[card.card_class] += 1
		update_display(card.card_class, class_counts[card.card_class])
	else:
		class_counts[card.card_class] = 1
		spawn_trait_display(card.card_class)
	
	send_signal_to_update_trait_buffs()
	
	
func send_signal_to_update_trait_buffs():
	request_alter_trait_buff.emit(race_counts, class_counts)
	

	

func remove_trait_from_dict(card):
	race_counts[card.race] -= 1
	class_counts[card.card_class] -= 1
	update_display(card.race, race_counts[card.race])
	update_display(card.card_class, class_counts[card.card_class])
	# Remove 1 and update display ^^^^
	
	# If hits 0, remove both count and display
	if race_counts[card.race] == 0:
		race_counts.erase(card.race)
		remove_trait_display(card.race)
	if class_counts[card.card_class] == 0:
		class_counts.erase(card.card_class)
		remove_trait_display(card.card_class)
		
	send_signal_to_update_trait_buffs()


func spawn_trait_display(trait_name):
	var new_display = trait_display.instantiate()
	new_display.trait_name = trait_name
	trait_box.add_child(new_display)
	new_display.set_trait_name(trait_name)
	new_display.trait_counter = 1
	update_display(trait_name, new_display.trait_counter)
	

func remove_trait_display(trait_name_ref):
	for child in trait_box.get_children():
		if child.trait_name == trait_name_ref:
			child.queue_free()
			break
	

func update_display(trait_name_ref, count):
	for display in trait_box.get_children():
		if display.trait_name == trait_name_ref:
			display.trait_counter = count
			display.update_details()
	#send_signal_to_update_trait_buffs()
	
			
