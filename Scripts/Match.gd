extends Node

export var max_rounds = 3

var players_points = [0, 0]
var rounds = 0

func _ready():
	self.start_round()
	
func start_round():
	$Round.start_round(5, rounds, 0, 1)
	
func finish_round(winner):
	players_points[winner] += 1
	rounds += 1
	
	if players_points[winner] > max_rounds / 2:
		finish_match(winner)
		
func finish_match(winner):
	print ("Winner: Player " + str(winner +1))
