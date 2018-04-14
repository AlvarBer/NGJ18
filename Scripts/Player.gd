extends KinematicBody2D


export var player_idx = 0
export var acceleration = 500
export var deceleration = 400
export var max_speed = 300
export var dash_acceleration = 1200
export var dash_max_speed = 800
export var dash_duration = 0.5
enum State {IDLE, ACCELERATE, MOVE, DECELERATE, DASH}
var state = IDLE
var direction = Vector2()
var last_direction = Vector2(1, 1)
var speed = 0
var dash_direction
var done_dashing = false

var collectible

func _ready():
	$Tween.TweenProcessMode = $Tween.TWEEN_PROCESS_PHYSICS

func _physics_process(delta):
	# Input parsing
	self.direction.x = (
		float(Input.is_action_pressed("player_%d_move_right" % self.player_idx)) -
		float(Input.is_action_pressed("player_%d_move_left" % self.player_idx))
	)
	self.direction.y = (
		float(Input.is_action_pressed("player_%d_move_down" % self.player_idx)) -
		float(Input.is_action_pressed("player_%d_move_up" % self.player_idx))
	)

	# State changes
	var new_state = self.state
	match self.state:
		IDLE:
			if Input.is_action_just_pressed("player_%d_dash" % self.player_idx):
				new_state = DASH
			elif self.direction:
				new_state = ACCELERATE
		ACCELERATE:
			if Input.is_action_just_pressed("player_%d_dash" % self.player_idx):
				new_state = DASH
			elif speed == self.max_speed:
				new_state = MOVE
		MOVE:
			if Input.is_action_just_pressed("player_%d_dash" % self.player_idx):
				new_state = DASH
			elif not self.direction:
				new_state = DECELERATE
		DECELERATE:
			if Input.is_action_just_pressed("player_%d_dash" % self.player_idx):
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
			self.speed = clamp(self.speed, 0, self.max_speed)
			self.move_(self.last_direction, self.speed, delta)
		[_, MOVE]:
			self.move_(self.last_direction, self.speed, delta)
		[_, DECELERATE]:
			self.speed -= self.deceleration * delta
			self.speed = clamp(self.speed, 0, self.max_speed)
			self.move_(self.last_direction, self.speed, delta)
		[DASH, DASH]:
			self.move_(self.dash_direction.normalized(), self.speed, self.delta)
		[_, DASH]:
			$Tween.interpolate_property(
				self, "speed", self.speed, self.dash_max_speed, self.dash_duration, $Tween.TRANS_BACK, $Tween.EASE_OUT
			)
			self.dash_direction = self.last_direction
			$Tween.start()
			self._end_dash()
	self.state = new_state

func move_(direction, speed, delta):
	var velocity = direction * speed * delta
	var collision_info = self.move_and_collide(velocity)
	if collision_info:
		print(direction)
		print(collision_info.normal)

func move(delta):
	self.speed = clamp(self.speed, 0, self.max_speed)
	var motion = self.last_direction.normalized() * self.speed * delta
	var collision_info = self.move_and_collide(motion)


func _end_dash():
	yield($Tween, "tween_completed")
	self.done_dashing = true
