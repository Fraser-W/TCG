extends Control

var current_star : int = 0 # You can also store other data like star level here if needed
@export var is_player_summon : bool
@export var slot_number : int
@onready var hand = $"../../player_deck_handler/hand_handler"
#@onready var original_size = self.size

signal card_play_check_continued(summon_slot, card)


# When a card is released, fire a new signal to battle handler with the current node
# that is connected. Thats handled by the _mouse_entered functions
func _on_card_play_check_signal(card):
	card_play_check_continued.emit(self, card)


# These help the battle handler determine which summon node mouse is in
func _on_area_2d_mouse_entered():
	hand.connect("card_play_check", _on_card_play_check_signal)
	
	
	
func _on_area_2d_mouse_exited():
	hand.disconnect("card_play_check", _on_card_play_check_signal)
	
	
	
