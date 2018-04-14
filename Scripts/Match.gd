extends Node

export var max_rounds = 3

var players_points = [0, 0]
var rounds = 0

func _ready():
	randomize()
	self.start_round()
	
func start_round():
	$Round.start_round(5, rounds, 0, 1)
	
func finish_round(winner):
	self.players_points[winner] += 1
	self.rounds += 1
	
	if self.players_points[winner] > self.max_rounds / 2:
		self.finish_match(winner)
		
func finish_match(winner):
	print("Winner: Player " + str(winner +1))
