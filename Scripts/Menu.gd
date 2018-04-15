extends Node

func _ready():
	$Start.grab_focus()


func _on_Start_pressed():
	get_node("/root/Global").goto_scene("res://Scenes/Match.tscn")
