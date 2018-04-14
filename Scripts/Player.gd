extends KinematicBody2D


export var acceleration = 500
export var deceleration = 400
export var max_speed = 300
export var dash_acceleration = 1200
export var dash_max_speed = 800
export var dash_duration = 0.5
enum State {IDLE, ACCELERATE, MOVE, DECELERATE, DASH}
var state = IDLE
var direction = Vector2()
var last_direction = Vector2()
var speed = 0
var dash_direction
var done_dashing = false

var collectible

func _ready():
	self.change_state(IDLE)
	self.set_meta("is_defender", true)
	$Tween.TweenProcessMode = $Tween.TWEEN_PROCESS_PHYSICS

func _physics_process(delta):
	# Input parsing
	self.direction.x = float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left"))
	self.direction.y = float(Input.is_action_pressed("move_down")) - float(Input.is_action_pressed("move_up"))

	# Laura changes
	if Input.is_action_pressed("ui_select"):
		force_drop()

	# State changes
	var new_state = self.state
	match self.state:
		IDLE:
			if Input.is_action_just_pressed("dash"):
				new_state = DASH
			elif self.direction:
				new_state = ACCELERATE
		ACCELERATE:
			if Input.is_action_just_pressed("dash"):
				new_state = DASH
			elif speed == self.max_speed:
				new_state = MOVE
		MOVE:
			if Input.is_action_just_pressed("dash"):
				new_state = DASH
			elif not self.direction:
				new_state = DECELERATE
		DECELERATE:
			if Input.is_action_just_pressed("dash"):
				new_state = DASH
			elif not self.speed:
				new_state = IDLE
			elif self.direction:
				new_state = ACCELERATE
		DASH:
			if self.done_dashing:
				new_state = IDLE
				self.done_dashing = false
	self.change_state(new_state, delta)

	# Save direction if it has changed
	if self.direction:
		self.last_direction = self.direction

func change_state(new_state, delta):
	match [self.state, new_state]:
		[_, IDLE]:
			pass
		[_, ACCELERATE]:
			self.speed += self.acceleration * delta
			move(delta)
		[_, MOVE]:
			move(delta)
		[_, DECELERATE]:
			self.speed -= self.deceleration * delta
			move(delta)
		[DASH, DASH]:
			self.move_and_collide(self.dash_direction.normalized() * self.speed * delta)
		[_, DASH]:
			$Tween.interpolate_property(
				self, "speed", self.speed, self.dash_max_speed, self.dash_duration, $Tween.TRANS_BACK, $Tween.EASE_OUT
			)
			self.dash_direction = self.last_direction
			$Tween.start()
			_end_dash()
	self.state = new_state

func move(delta):
	self.speed = clamp(self.speed, 0, self.max_speed)
	var motion = self.last_direction.normalized() * self.speed * delta
	self.move_and_collide(motion)
	
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

func _end_dash():
	yield($Tween, "tween_completed")
	self.done_dashing = true
