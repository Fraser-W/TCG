extends Node
# Index and card number 0000
const index : int = 0
const card_cost : int = 2
const card_name : String = "Arthur Pendragon"
# Star rarity
const star : int = 1
# Type (monster, equipment etc)
const type : String = "Monster"
const race : String = "Human" 
const card_class : String = "Warrior"

# UPDATE ANY SKILL TEXTS IF STATS CHANGE
# stats
const health : int = 10
const attack_score : int = 8
const amour_score : int = 0
const attack_speed : int = 1


const passive_skill_text = ""
const active_skill_text = "Deal {X} Damage"

const card_art = "res://Scripts/Cards/Monsters/arthur_pendragon/arthur_pendragon_AI_02.png"
const card_icon = "res://Scripts/Cards/Monsters/arthur_pendragon/arthur_pendragon_AI_icon.png"

func passive_skill(_effect_handler, _board_id):
	pass

func active_skill(board_id, effect_handler):
	effect_handler.damage_effect(board_id, attack_score)
	
