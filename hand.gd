class_name Hand
extends HBoxContainer

const card_scene := preload("res://card.tscn")

signal card_requested()
signal card_play_check(card)

@onready var active_hand : bool




# Previously check for hand size but was causing issues when trying to draw the correct
# amount so moved that check to battle handler
func add_card():
	card_requested.emit()
	
# Send what card was released to battle_handler
func _on_card_released_signal(card):
	card_play_check.emit(card)
	
func connect_card_released(card):
	if !card.is_connected("card_released", _on_card_released_signal):
		card.connect("card_released", _on_card_released_signal)
	
