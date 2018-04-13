extends KinematicBody2D


export var acceleration = 25
export var max_speed = 100
enum State {IDLE, MOVE, DASH}
var state
var direction = Vector2()

func _ready():
	self.change_state(IDLE)

func _process(delta):
	var new_direction = Vector2()
	new_direction.x = float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left"))
	new_direction.y = float(Input.is_action_pressed("move_down")) - float(Input.is_action_pressed("move_up"))
	if self.state == IDLE and new_direction:
		self.change_state(MOVE)
		self.move_and_collide(new_direction * speed * delta)
	elif self.state == MOVE:
		if not new_direction:
			self.change_state(IDLE)
		self.move_and_collide(new_direction * speed * delta)

func change_state(new_state):
	match new_state:
		IDLE:
			print("Idling")
		MOVE:
			print("Moving")
	self.state = new_state

func move():
	pass
