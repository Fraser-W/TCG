extends Control

@onready var trait_name : String
@onready var trait_counter : int
@onready var trait_text : String = "test"

func update_details():
	$trait_icon/current_count_background/current_count.bbcode_text = "[center]" + str(trait_counter) + "[/center]"
	
func set_trait_name(trait_string):
	$transparent_background/trait_name.text = trait_name
	if trait_string == "Human":
		trait_text = "Humans gain bonus HP"
	$TextInfoBackground/RichTextLabel.text = trait_text
	


func _on_area_2d_mouse_entered():
	$TextInfoBackground.visible = true


func _on_area_2d_mouse_exited():
	$TextInfoBackground.visible = false
