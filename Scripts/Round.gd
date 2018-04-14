extends Node

enum State { PREPARATION, RUNNING }

export var map_scenes = [ 
	preload("res://Scenes/Map1.tscn"), 
	preload("res://Scenes/Map2.tscn"), 
	preload("res://Scenes/Map3.tscn")
]

export var defender_scene = preload("res://Scenes/Defender.tscn")
export var attacker_scene = preload("res://Scenes/Attacker.tscn")

var time
var round_duration
var state = State.PREPARATION
var map
var defender
var defender_idx
var attacker
var attacker_idx
var winner

var start_timer
var finish_timer

func _ready():
	self.start_timer = $StartTimer
	self.start_timer.one_shot = true
	self.start_timer.set_wait_time(2)
	self.start_timer.connect("timeout", self, "on_start_timer_timeout")
	
	self.finish_timer = $FinishTimer
	self.finish_timer.one_shot = true
	self.finish_timer.set_wait_time(2)
	self.finish_timer.connect("timeout", self, "on_finish_timer_timeout")
	
	$Start.visible = false
	$Finish.visible = false

func _process(delta):
	if self.state == State.RUNNING:
		self.time -= delta
		
		if self.time < 0:
			self.finish_round(self.attacker.player_idx)
			
			$Time.visible = false
		else:
			$Time.visible = true
			$Time.text = str(self.time).pad_decimals(2)

func start_round(duration, round_number, defender, attacker):
	self.round_duration = duration
	self.time = duration
	self.defender_idx = defender
	self.attacker_idx = attacker
	
	$Start.visible = true
	$Start/Round.text = "Round " + str(round_number + 1)
	get_node("Start/Player%d/Role" % defender).text = "Defender"
	get_node("Start/Player%d/Role" % attacker).text = "Attacker"
	
	self.start_timer.start()
	
	
func finish_round(winner):
	print("Finish Round")
	self.winner = winner 
	self.state = PREPARATION
	self.remove_child(map)
	self.remove_child(defender)
	self.remove_child(attacker)
	
	$Finish.visible = true
	$Finish/Winner/Player.text = "Player %d" % (winner + 1)
	
	self.finish_timer.start()
	
	
func on_start_timer_timeout():
	var random_idx = randi() % len(self.map_scenes)
	self.map = self.map_scenes[random_idx].instance()
	self.add_child(self.map)
	
	self.defender = self.defender_scene.instance()
	self.defender.player_idx = defender_idx
	self.defender.position = map.get_node("PosPlayer%d" % defender_idx).position;
	self.add_child(self.defender)
	
	self.attacker = self.attacker_scene.instance()
	self.attacker.player_idx = attacker_idx
	self.attacker.position = map.get_node("PosPlayer%d" % attacker_idx).position;
	self.add_child(self.attacker)
	
	$Start.visible = false
	self.state = State.RUNNING
	
func on_finish_timer_timeout():
	print("parent finish round")
	self.get_parent().finish_round(self.winner)
	
	$Finish.visible = false;
