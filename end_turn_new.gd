extends Control


signal end_turn_clicked()

@onready var mouse_in : bool



func _on_texture_button_button_down():
	pass

func _on_texture_button_button_up():
	if mouse_in == true:
		end_turn_clicked.emit()
		
	
		
func disable_button():
	$button_disabled_colour.visible = true
	$TextureButton.disabled = true
	
func enable_button():
	$button_disabled_colour.visible = false
	$TextureButton.disabled = false


func _on_area_2d_mouse_entered():
	$hover.visible = true
	mouse_in = true
	


func _on_area_2d_mouse_exited():
	$hover.visible = false
	mouse_in = false
