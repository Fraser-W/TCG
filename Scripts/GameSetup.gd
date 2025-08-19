extends Node2D



func host_setup():
	$GameManager.is_player_turn = true
	$GameManager.start_next_card_phase()
	$GameManager.host_hero_id_setup()
	
	
	
func client_setup():
	$GameManager.is_player_turn = false
	$GameManager.player_had_previous_first_turn = true
	$GameManager.start_next_card_phase()
	$GameManager.client_hero_id_setup()
