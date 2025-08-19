extends Node2D

@onready var PORT = 5000
# The IP address of the server
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()

@export var player_field_scene : PackedScene
@export var opponent_field_scene : PackedScene
@export var deck_creator : PackedScene


func _on_host_button_pressed():
	disable_buttons()

	
	# Set multiplayer object to server
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(self._on_peer_connected)
	
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	
func _on_join_button_pressed():
	disable_buttons()
	
	# Create Client
	peer.create_client(SERVER_ADDRESS, PORT)
	
	multiplayer.multiplayer_peer = peer
	
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	
	
	var opponent_scene = opponent_field_scene.instantiate()
	add_child(opponent_scene)
	
	# Setup game for joined player
	player_scene.client_setup()

func _on_peer_connected(_peer_id):
	# Spawn Opponent for host
	var opponent_scene = opponent_field_scene.instantiate()
	add_child(opponent_scene)
	get_node("PlayerField").host_setup()
	

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
	$PortNumber.visible = false
	$DeckCreator.visible = false
	$DeckCreator.disabled = true


func _on_port_number_text_changed(new_text):
	PORT = int(new_text)

func end_game(result):
	get_node("PlayerField").queue_free()
	get_node("OpponentField").queue_free()
	if result == 1:
		$Win.visible = true
	else:
		$Lose.visible = true


func _on_deck_creator_pressed():
	disable_buttons()
	var deck_creator_scene = deck_creator.instantiate()
	add_child(deck_creator_scene)
	
