extends Node2D

@onready var flag = false
@onready var card_scene = preload("res://card.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
func _input(event):
	if event.is_action_pressed("left_click") && flag == true:
		pass
		#Hand.add_card()



func _on_area_2d_mouse_entered():
	flag = true # Replace with function body.
	


func _on_area_2d_mouse_exited():
	flag = false # Replace with function body.
	
