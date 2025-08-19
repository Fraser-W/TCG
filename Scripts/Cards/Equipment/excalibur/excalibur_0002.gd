extends Node
# Index and card number 0000
const index : int = 2
const card_cost : int = 1
const card_name : String = "Excalibur"

# Type (monster, equipment etc)
const type : String = "Weapon"

const active_skill_text = "Transform 'Arthur Pendragon' into 'King Arthur'"

const card_art = "res://Scripts/Cards/Equipment/excalibur/excalibur_AI.png"
const card_icon = "res://Scripts/Cards/Equipment/excalibur/excalibur_AI_icon.png"



func active_skill(board_id, effect_handler):
	effect_handler.transform_effect(board_id, "res://Scripts/Cards/Monsters/king_arthur/king_arthur_0001.gd")
	
