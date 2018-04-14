extends Node

func _ready():
	$MarginContainer/VBoxContainer/Start.grab_focus()


func _on_Start_pressed():
	print ("Pressed")
	get_node("/root/Global").goto_scene("res://Scenes/Match.tscn")
