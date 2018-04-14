extends KinematicBody2D


export var player_idx = 0
export var acceleration = 500
export var deceleration = 800
export var max_speed = 300
export var dash_max_speed = 800
export var dash_duration = 0.5
enum State {IDLE, ACCELERATE, MOVE, DECELERATE, DASH, BOUNCE}
var state = IDLE
var direction = Vector2()
var last_direction = Vector2(1, 1)
var speed = 0
var dash_direction
var done_dashing = false
var bounce_direction
var done_bouncing = false
var bounce_duration = 0.3

func _ready():
	$Tween.TweenProcessMode = $Tween.TWEEN_PROCESS_PHYSICS
	self.execute_state(IDLE, 0)

func _physics_process(delta):
	# State-independent Input parsing
	if len(Input.get_connected_joypads()) > self.player_idx:
		self.direction = Vector2(
			Input.get_joy_axis(self.player_idx, JOY_AXIS_0),
			Input.get_joy_axis(self.player_idx, JOY_AXIS_1)
		)
		if self.direction.length() < 0.2:
			self.direction = Vector2()
	else:
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
	if self.bounce_direction:
		new_state = BOUNCE
	else:
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
				elif not self.direction:
					new_state = DECELERATE
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
			BOUNCE:
				if self.done_bouncing:
					new_state = IDLE
	self.execute_state(new_state, delta)

	# Save direction if it has changed
	if self.direction:
		self.last_direction = self.direction

func execute_state(new_state, delta):
	match [self.state, new_state]:
		[_, IDLE]:
			self.modulate = Color("#7d7d7d")
		[_, ACCELERATE]:
			self.speed += self.acceleration * delta
			self.speed = clamp(self.speed, 0, self.max_speed)
			self.move(self.last_direction * self.speed, delta)
			self.modulate = Color("#bebebe")
		[_, MOVE]:
			self.move(self.last_direction * self.speed, delta)
			self.modulate = Color("#ffffff")
		[_, DECELERATE]:
			self.speed -= self.deceleration * delta
			self.speed = clamp(self.speed, 0, self.max_speed)
			self.move(self.last_direction * self.speed, delta)
			self.modulate = Color("#bebebe")
		[DASH, DASH]:
			self.move(self.dash_direction * self.speed, delta)
		[_, DASH]:
			self.done_dashing = false
			$Tween.interpolate_property(
				self, "speed", self.speed, self.dash_max_speed, self.dash_duration, $Tween.TRANS_BACK, $Tween.EASE_OUT
			)
			self.dash_direction = self.last_direction
			$Tween.start()
			self._end_dash()
			self.modulate = Color("#2b2b2b")
		[BOUNCE, BOUNCE]:
			self.move(self.speed * self.bounce_direction, delta)
		[_, BOUNCE]:
			self.done_bouncing = false
			$Tween.stop_all()
			$Tween.interpolate_property(
				self, "speed", self.speed, 0, self.bounce_duration, $Tween.TRANS_LINEAR, $Tween.EASE_IN_OUT
			)
			$Tween.start()
			self._end_bounce()
	self.state = new_state

func move(velocity, delta):
	var collision_info = self.move_and_collide(velocity * delta)
	if collision_info:
		self.bounce_direction = velocity.bounce(collision_info.normal).normalized()
	return collision_info

func _end_dash():
	yield($Tween, "tween_completed")
	self.done_dashing = true

func _end_bounce():
	yield($Tween, "tween_completed")
	self.done_bouncing = true
	self.bounce_direction = null
