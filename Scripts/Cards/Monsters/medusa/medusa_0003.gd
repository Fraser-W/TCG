extends Node
const index : int = 3
const card_cost : int = 2
const card_name : String = "Medusa"
# Star rarity
const star : int = 1
# Type (monster, equipment etc)
const type : String = "Monster"
const race : String = "Mythical" 
const card_class : String = "Sorceress"

# UPDATE ANY SKILL TEXTS IF STATS CHANGE
# stats
const health : int = 10
const attack_score : int = 8
const amour_score : int = 0
const attack_speed : int = 1


const passive_skill_text = "Freeze enemies directly infront of Medusa"
const active_skill_text = "Deal {X} Damage"

const card_art = "res://Scripts/Cards/Monsters/medusa/medusa_AI.png"
const card_icon = "res://Scripts/Cards/Monsters/medusa/medusa_AI_icon.png"

func passive_skill(effect_handler, board_id):
	effect_handler.freeze_across(board_id)
	#enemies in front of are frozen as stone

func active_skill(board_id, effect_handler):
	effect_handler.damage_effect(board_id, attack_score)
