extends HBoxContainer


const card_scene := preload("res://card.tscn")

signal enemy_card_requested()


@export var max_hand_size : int


func add_card():
	# If hand size is below 10, request a card
	var current_card_count = get_child_count()
	if current_card_count < max_hand_size:
		enemy_card_requested.emit()
	
# Send what card was released to battle_handler
#func _on_card_released_signal(card):
	#card_play_check.emit(card)
	
#func connect_card_released(card):
	#card.connect("card_released", _on_card_released_signal)
