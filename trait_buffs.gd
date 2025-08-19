extends Node

class_name TraitBuffs

@onready var human_buff : int = 5 # BONUS HEALTH

@onready var active_race_bonuses : Dictionary = {
	"Human" : 0,
	"Orc" : 0
}
@onready var active_class_bonuses : Dictionary = {
	"Warrior" : 0
}

@onready var opponent_race_counts : Dictionary
@onready var opponent_class_counts : Dictionary

@onready var active_opponent_race_bonuses : Dictionary = {
	"Human" : 0,
	"Orc" : 0
}
@onready var active_opponent_class_bonuses : Dictionary = {
	"Warrior" : 0
}
const race_dictionary : Dictionary = {
	"Human" : [3,4,5],
	"Orc" : []
	
	
}
const class_dictionary : Dictionary = {
	"Warrior" : [],
	"Mage" : []
}


'''
Apply buffs to each card
'''

	
# Array are nodes
func alter_buffs(cards : Array, race_counts : Dictionary, class_counts : Dictionary):
	'''---RACE---'''
	# Looping through orc as well, even with no orc on field
	for race in race_dictionary.keys(): # "Human"
		var count = race_counts.get(race, 0) # 3
		var thresholds = race_dictionary[race] # [3,4,5]
		var new_level = 0
	
		# Determine the highest level met by current count
		for i in range(thresholds.size()):
			if count >= thresholds[i]:
				new_level = i + 1
			else:
				break
				
		var current_level = active_race_bonuses.get(race, 0)
		if new_level > current_level:
			# Apply new bonus level
			apply_race_bonus(cards, race, current_level + 1, new_level)
			active_race_bonuses[race] = new_level
		elif new_level < current_level:
			
			# Remove higher level bonuses that no longer apply
			remove_race_bonus(cards, race, new_level)
			active_race_bonuses[race] = new_level	
		## else: same level, do nothing
		
	'''---CLASS---'''
	# Looping through orc as well, even with no orc on field
	for card_class in class_dictionary.keys(): # "Warrior"
		var count = class_counts.get(card_class, 0) # 3
		var thresholds = class_dictionary[card_class] # [3,4,5]
		var new_level = 0
	
		# Determine the highest level met by current count
		for i in range(thresholds.size()):
			if count >= thresholds[i]:
				new_level = i + 1
			else:
				break
				
		var current_level = active_class_bonuses.get(card_class, 0)
		if new_level > current_level:
			# Apply new bonus level
			apply_class_bonus(cards, card_class, current_level + 1, new_level)
			active_class_bonuses[card_class] = new_level
		elif new_level < current_level:
			
			# Remove higher level bonuses that no longer apply
			remove_class_bonus(cards, card_class, new_level)
			active_class_bonuses[card_class] = new_level	
		## else: same level, do nothing
	
	
	
func alter_opponent_buffs(cards : Array):
	'''---RACE---'''
	# Looping through orc as well, even with no orc on field
	for race in race_dictionary.keys(): # "Human"
		var count = opponent_race_counts.get(race, 0) # 3
		var thresholds = race_dictionary[race] # [3,4,5]
		var new_level = 0
	
		# Determine the highest level met by current count
		for i in range(thresholds.size()):
			if count >= thresholds[i]:
				new_level = i + 1
			else:
				break
				
		var current_level = active_opponent_race_bonuses.get(race, 0)
		if new_level > current_level:
			# Apply new bonus level
			apply_race_bonus(cards, race, current_level + 1, new_level)
			active_opponent_race_bonuses[race] = new_level
		elif new_level < current_level:
			# Remove higher level bonuses that no longer apply
			remove_race_bonus(cards, race, new_level)
			active_opponent_race_bonuses[race] = new_level	
		## else: same level, do nothing
	'''---CLASS---'''
	# Looping through orc as well, even with no orc on field
	for card_class in class_dictionary.keys(): # "Human"
		var count = opponent_class_counts.get(card_class, 0) # 3
		var thresholds = class_dictionary[card_class] # [3,4,5]
		var new_level = 0
	
		# Determine the highest level met by current count
		for i in range(thresholds.size()):
			if count >= thresholds[i]:
				new_level = i + 1
			else:
				break
				
		var current_level = active_opponent_class_bonuses.get(card_class, 0)
		if new_level > current_level:
			# Apply new bonus level
			apply_class_bonus(cards, card_class, current_level + 1, new_level)
			active_opponent_class_bonuses[card_class] = new_level
		elif new_level < current_level:
			# Remove higher level bonuses that no longer apply
			remove_class_bonus(cards, card_class, new_level)
			active_opponent_class_bonuses[card_class] = new_level	
		## else: same level, do nothing


'''---RACE---'''

func apply_race_bonus(cards, race: String, from_level: int, to_level: int):
	for card in cards:
		if card.race == race:
			var current_level = card.race_buff_level
			var new_bonus_levels = to_level - current_level
			if new_bonus_levels > 0:
				if race == "Human":
					card.health += new_bonus_levels * human_buff
				card.race_buff_level = to_level
				card.refresh_ui()
	

	
	
func remove_race_bonus(cards : Array, race: String, new_level: int):
	for card in cards:
		if card.race == race:
			var current_level = card.race_buff_level
			#var new_bonus_levels = to_level - current_level
			if race == "Human":
				card.health -= human_buff
			card.race_buff_level = new_level
			card.refresh_ui()
		#


func set_opponent_counts(race_counts, class_counts):
	opponent_race_counts = race_counts
	opponent_class_counts = class_counts
	
'''---CLASS---'''

func apply_class_bonus(cards, card_class: String, from_level: int, to_level: int):
	for card in cards:
		if card.card_class == card_class:
			var current_level = card.class_buff_level
			var new_bonus_levels = to_level - current_level
			if new_bonus_levels > 0:
				if card_class == "Warrior":
					pass
				card.class_buff_level = to_level
				card.refresh_ui()
	

	
	
func remove_class_bonus(cards : Array, card_class: String, new_level: int):
	for card in cards:
		if card.card_class == card_class:
			var current_level = card.class_buff_level
			#var new_bonus_levels = to_level - current_level
			if card_class == "Warrior":
				pass
			card.class_buff_level = new_level
			card.refresh_ui()
