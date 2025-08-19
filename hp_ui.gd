extends Control

@onready var hp_text = $hp
@onready var hp_bar = $TextureProgressBar


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	hp_text.text = str(hp_bar.value)
	
func refresh_hp_value(new_hp_value):
	hp_bar.max_value = new_hp_value
	hp_bar.value = new_hp_value

func refresh_ui(new_hp_value):
	hp_bar.value = new_hp_value
