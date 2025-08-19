
extends Control

class_name Card

enum State {DEFAULT, HAND, PLAY, MOUSE, DECK, DISCARD, GRAVE, DISABLED}

signal card_released(card_node, card_hand_position)
signal card_dead(card_board_id)
signal wanting_to_attack(card)
signal target_chosen(target_card)
signal card_picked_up()
signal card_returned_to_hand()

# Important Card Variables
@onready var card_name : String
@onready var card_index : int
@export var card_type : String
@onready var card_cost : int
@export var star_level : int
@onready var card_art : String
@onready var card_icon : String



# Monster
@onready var board_id : int
@onready var race : String
@onready var card_class : String
@onready var health : int
@onready var attack_score : int
@onready var amour_score : int
@onready var attack_speed : int
@onready var skill_count : int
@onready var passive_skill_text : String
@onready var active_skill_text : String
@onready var race_buff_level : int = 0
@onready var class_buff_level : int = 0
@onready var weapon_attached : bool = false
@onready var equipment_attached : bool = false
@onready var artifact_attached : bool = false




# Other Card Variables
@export var focus_size : float = 2.0
@onready var attack_scale : float = 1.2
@onready var shrunk_2d_size = Vector2(1/focus_size, 1/focus_size)
@onready var area2d_old_pos : Vector2
@onready var default_size = 1.0
@onready var original_size = self.size
@onready var mouse_in = false
@export var state : State
@onready var previous_state : State
@onready var card_hand_position = Vector2(0,0)
@onready var card_play_position = Vector2(0,0)
@onready var card_outline = $Focus
@onready var skills = []
	
# Combat variables
@onready var is_target = false
@export var player_card : bool
@onready var ability_hovering : int = 0
@onready var attack_turn : bool = false
@onready var can_be_played : bool = false



func _ready():
	# Add the card instance to the "cards" group when it is instantiated
	add_to_group("cards")
	
	
	
	
# Handles card dragging
func _process(_delta):
	# Drag the card and center around mouse
	if state == State.MOUSE:
		self.global_position = get_global_mouse_position() - (original_size/2)

func _on_area_2d_mouse_entered():
	'''----DEBUG----''' # Check needed card stats
	#if state == State.PLAY:
	#print("Card Index: " + str(card_index))
	#print("Card Name: " + card_name)
	#print("Board ID: " + str(board_id))
	#print("Race Buff Level: " + str(race_buff_level))
	#print("Health: " + str(health))
	'''----DEBUG----'''
	
	# Set mouse in variable to true
	mouse_in = true
	if player_card == true:
		# If in hand, focus in hand (WILL NEED TO CODE ELSEWHERE FOR TARGET)
		if state == State.HAND && can_be_played:
			area2d_old_pos = $Area2D.global_position
			self.pivot_offset = Vector2(original_size.x/2, original_size.y)
			self.scale = Vector2(focus_size,focus_size)
			self.z_index = 1
			$Area2D.scale = shrunk_2d_size
			$Area2D.global_position = area2d_old_pos
		elif state == State.PLAY && attack_turn:
			$CanAttackGlow.visible = true
	elif is_target && state == State.PLAY:
		$Focus.visible = true
		
		
			

func _on_area_2d_mouse_exited():
	# Set mouse in variable to false
	mouse_in = false
	if state == State.HAND:
		# Set size and position back to original
		self.scale = Vector2(default_size,default_size)
		self.z_index = 0
		$Area2D.scale = Vector2(default_size, default_size)
		$Area2D.position = Vector2(1,1)
	$Focus.visible = false
	$CanAttackGlow.visible = false
		

func _input(event):
	# If card is in hand state, move around
	if event.is_action_pressed("left_click"):
		
		if mouse_in == true:
			#'''----DEBUG----''' # Check needed card stats
			#if state == State.PLAY or state == State.DISABLED:
				#print("Card Name: " + card_name)
				#print("Board ID: " + str(board_id))
				#print("Card State: " + str(state))
				#print("Race Buff Level: " + str(race_buff_level))
				#print("Health: " + str(health))
				#print("-------------------------------------------------------")
			#'''----DEBUG----'''
			if player_card && can_be_played && state == State.HAND:
				previous_state = State.HAND
				card_hand_position = self.position
				#elif state == State.PLAY:
					#previous_state = State.PLAY
				state = State.MOUSE
				card_picked_up.emit()
				self.scale = Vector2(default_size,default_size)
				self.z_index = 0
				$Area2D.position = Vector2(1,1)
				$Area2D.scale = Vector2(default_size, default_size)
				
			elif attack_turn:
				wanting_to_attack.emit(self)
			elif is_target == true:
				target_chosen.emit(self)
		
			
	# When a card is released, snap it back to hand and call signal.
	# Game Manager will take over if it can be played and reparent accordingly
	elif event.is_action_released("left_click"):
		if state == State.MOUSE:
			if previous_state == State.HAND:
				self.position = card_hand_position
				state = State.HAND
				card_returned_to_hand.emit()
				card_released.emit(self)
		

func set_intial_ui():
	$NameBackground/NameText.bbcode_text = "[center]" + card_name + "[/center]"
	$CardArt.texture = load(card_art)
	$CardCost/CardCostDigit.bbcode_text =  "[center]" + str(card_cost) + "[/center]"
	if card_type == "Monster":
		$MonsterUI/hp_icon/hp_string.text = str(health)
		$MonsterUI/shield_icon/armour_string.text = str(amour_score)
		$MonsterUI/SwordsIcon/attack_string.text = str(attack_score)
		$MonsterUI/Race_Class_Text.bbcode_text = "[center]" + race + "/" + card_class + "[/center]"
		
	elif card_type == "Weapon":
		$MonsterUI.visible = false
		
	refresh_text()
	
		
		
func set_weapon_icon(icon_file_location : String):
	$MonsterUI/weapon_icon.texture = load(icon_file_location)
	
	
func refresh_text():
	$MonsterUI/PassiveSkillText.text = passive_skill_text
	$ActiveSkillText.text = active_skill_text.format({"X" : attack_score})
	
		
func refresh_ui():
	$MonsterUI/hp_icon/hp_string.text = str(health)
	$MonsterUI/shield_icon/armour_string.text = str(amour_score)
	$MonsterUI/SwordsIcon/attack_string.text = str(attack_score)
	refresh_text()
	
	if health <= 0:
		card_dead.emit(board_id)
		

func show_outline():
	card_outline.visible = true
	
func hide_outline():
	card_outline.visible = false

func become_target():
	is_target = true
	show_outline()
	
func no_longer_target():
	is_target = false
	hide_outline()
	
func show_card_back():
	$CardBack.visible = true
	
func show_playable():
	$PlayableGlow.visible = true
	
	
func hide_playable():
	$PlayableGlow.visible = false
	
func hide_card_back():
	$CardBack.visible = false

func ready_to_attack():
	attack_turn = true
	self.pivot_offset = Vector2(original_size.x/2, original_size.y/2)
	self.scale = Vector2(attack_scale,attack_scale)
	
func stand_down():
	attack_turn = false
	self.scale = Vector2(1,1)

func freeze():
	state = State.DISABLED
	$MonsterUI/stone_effect.visible = true
	
func unfreeze():
	state = State.PLAY
	$MonsterUI/stone_effect.visible = false
