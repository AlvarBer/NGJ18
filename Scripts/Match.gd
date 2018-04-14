extends Node

export var max_rounds = 3
export var round_duration = 10

var players_points = [0, 0]
var rounds = 0

var defender_idx
var attacker_idx

func _ready():
	randomize()
	$Results.visible = false
	self.start_match()

func start_match():
	self.defender_idx = randi() % 2
	self.attacker_idx = 1 - defender_idx
	self.start_round(true)

func finish_match():
	if self.players_points[0] > self.players_points[1]:
		self.force_finish_match(0)
	else:
		self.force_finish_match(1)

func force_finish_match(winner):
	print("Winner: Player " + str(winner + 1))
	$Results.visible = true
	$Results/Restart.grab_focus()
	$Results/Player1/Points.text = str(self.players_points[0])
	$Results/Player2/Points.text = str(self.players_points[1])

func start_round(first_round):
	if not first_round:
		var tmp = self.defender_idx
		self.defender_idx = self.attacker_idx
		self.attacker_idx = tmp
	$Round.start_round(round_duration, rounds, defender_idx, attacker_idx)

func finish_round(winner):
	self.players_points[winner] += 1
	self.rounds += 1

	if self.players_points[winner] > self.max_rounds / 2:
		self.force_finish_match(winner)
	elif self.rounds < self.max_rounds:
		start_round(false)
	else:
		self.finish_match()


func _on_Restart_pressed():
	players_points = [0, 0]
	rounds = 0
	$Results.visible = false
	self.start_match()
