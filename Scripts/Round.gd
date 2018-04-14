extends Node

export var maps = [ 
	preload("res://Scenes/Map1.tscn"), 
	preload("res://Scenes/Map2.tscn"), 
	preload("res://Scenes/Map3.tscn")
]

export var defender = preload("res://Scenes/Defender.tscn")
export var attacker = preload("res://Scenes/Attacker.tscn")

func start_round(duration, round_number, defender, attacker):
	var random_idx = randi() % len(maps)
	var map = self.maps[random_idx].instance()
	self.add_child(map)
	
	var d = self.defender.instance()
	d.player_idx = defender
	d.position = map.get_node("PosPlayer" + str(defender)).position;
	self.add_child(d)
	
	var a = self.attacker.instance()
	a.player_idx = attacker
	a.position = map.get_node("PosPlayer" + str(attacker)).position;
	self.add_child(a)