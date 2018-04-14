extends KinematicBody2D


export var acceleration = 500
export var deceleration = 300
export var max_speed = 300
enum State {IDLE, MOVE, DASH}
var state
var direction = Vector2()
var last_direction = Vector2()
var speed = 0

var collectible

func _ready():
	self.change_state(IDLE)
	self.set_meta("is_defender", true)

func _process(delta):
	if self.direction:
		self.last_direction = direction
		
	self.direction.x = float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left"))
	self.direction.y = float(Input.is_action_pressed("move_down")) - float(Input.is_action_pressed("move_up"))
	
	if self.state == IDLE and self.direction:
		self.change_state(MOVE)
	elif self.state == MOVE and not self.direction:
		self.change_state(IDLE)
			
	self.move(delta)
	
	if Input.is_action_pressed("ui_select"):
		force_drop()

func change_state(new_state):
	match new_state:
		IDLE:
			pass
		MOVE:
			pass
	self.state = new_state

func move(delta):
	if self.direction:
		self.speed += self.acceleration * delta
	else:
		self.speed -= self.deceleration * delta
	self.speed = clamp(self.speed, 0, self.max_speed)
		
	var motion = self.last_direction.normalized() * self.speed * delta
	move_and_collide(motion)
	
func pick(col):
	if not self.collectible:
		self.collectible = col
		self.collectible.get_parent().remove_child(self.collectible)
		$PickPivot.add_child(self.collectible)
		self.collectible.position = Vector2()
	
func drop(base):
	if self.collectible:
		$PickPivot.remove_child(self.collectible)
		base.add_child(self.collectible)
		self.collectible.position = Vector2()
		self.collectible = null
		
func force_drop():
	if self.collectible:
		$PickPivot.remove_child(self.collectible)
		get_parent().add_child(self.collectible)
		self.collectible.position = self.position
		self.collectible = null