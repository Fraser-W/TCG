extends Control

# HP Scene variables
const hp_scene := preload("res://hp_ui.tscn")
@onready var hp = hp_scene.instantiate()

# HP bar positioning
@onready var player_hp_y_height = 15
@onready var enemy_hp_y_height = 125

# Is player
@export var is_player : bool
@onready var board_id : int

# Hero variables
@export var max_hp : int = 100
@onready var health : int = max_hp
@onready var is_target : bool = false
@onready var amour_score : int = 0

# Mouse variables
@onready var mouse_in : bool

# Signals
signal target_chosen(target)



func _ready():
	
	# Spawn HP bar and position it
	
	self.add_child(hp)
	if is_player == true:
		hp.global_position = Vector2(self.global_position.x, (self.global_position.y - player_hp_y_height))
	else:
		hp.global_position = Vector2(self.global_position.x, (self.global_position.y + enemy_hp_y_height))
		
	# Set HP
	hp.refresh_hp_value(max_hp)
	
func become_target():
	is_target = true
	$focus.visible = true
	
func no_longer_target():
	is_target = false
	$focus.visible = false

func _input(event):
	# If card is in hand state, move around
	if event.is_action_pressed("left_click"):
		if mouse_in == true && is_target == true:
			target_chosen.emit(self)



func _on_area_2d_mouse_entered():
	mouse_in = true
	if is_target:
		$focus.visible = true


func _on_area_2d_mouse_exited():
	mouse_in = false
	$focus.visible = false
	
func refresh_ui():
	hp.refresh_ui(health)
	if health <= 0 && is_player:
		get_parent().game_end_loss()

func toggle_target():
	is_target = !is_target
