extends HBoxContainer
const card_scene := preload("res://card.tscn")
@onready var card_list_gd = load("res://Scripts/Cards/CardList.gd") 
@onready var card_list = card_list_gd.complete_card_list

var temp_deck = [
	0,1,2,3,4
]
@onready var summon_slots = [
	$enemy_summon_01,
	$enemy_summon_02,
	$enemy_summon_03,
	$enemy_summon_04,
	$enemy_summon_05
]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	'for slot in summon_slots:
		var new_card := card_scene.instantiate()
		var random_index = randi() % temp_deck.size()
		#var card_info = temp_deck[random_index]
		var card_path = card_list[temp_deck[random_index]]
		var card_script = load(card_path).new()
		slot.add_child(new_card)
		new_card.state = new_card.State.PLAY
		set_card(new_card, card_script.card_art, card_script)
		# Remove card from deck so it cant be chosen again
		temp_deck.remove_at(random_index)'
		




func set_card(card, art_path, card_script):
	# Set type and star level (All cards have these)
	card.card_type = card_script.type
	card.star_level = card_script.star
	# If a monster, set monster stats
	if card_script.type == 0:
		card.card_index = card_script.index
		card.health = card_script.health
		card.attack_score = card_script.attack_score
		card.amour_score = card_script.amour_score
		card.resist_score = card_script.resist_score
		card.attack_type = card_script.attack_type# 0 = physical, 1 = magic,2 = both, 3 = true damage
		card.refresh_ui()
		
	var card_image = card.get_node("texture")
	card_image.texture = load(art_path)
	card.set_stars()
