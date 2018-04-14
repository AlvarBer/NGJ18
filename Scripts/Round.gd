extends Node

export var maps = [ 
	preload("res://Scenes/Map1.tscn"), 
	preload("res://Scenes/Map2.tscn"), 
	preload("res://Scenes/Map3.tscn")
]

func start_round(duration, round_number, defender, attacker):
	var random_idx = randi() % len(maps)
	var map = maps[random_idx].instance()
	self.add_child(map)
