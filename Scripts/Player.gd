extends KinematicBody2D


export var player_idx = 0
export var acceleration = 500
export var deceleration = 1000
export var max_speed = 300
export var dash_max_speed = 1000
export var dash_duration = 0.3
export var bounce_duration = 0.3
export var dashed_factor = 2
enum State {IDLE, ACCELERATE, MOVE, DECELERATE, DASH, BOUNCE}
var state = IDLE
var direction = Vector2()
var last_direction = Vector2(1, 1)
var speed = 0
var dash_direction
var done_dashing = false
var bounce_direction
var done_bouncing = false

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
					new_state = ACCELERATE
	self.execute_state(new_state, delta)

	# Save direction if it has changed
	if self.direction:
		self.last_direction = self.direction

func execute_state(new_state, delta):
	var old_state = self.state
	self.state = new_state
	match [old_state, new_state]:
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
			self.modulate = Color("#be77ff")
			yield($Tween, "tween_completed")
			self.done_dashing = true
		[BOUNCE, BOUNCE]:
			self.move(self.speed * self.bounce_direction, delta)
		[_, BOUNCE]:
			self.modulate = Color("#feffae")
			self.done_bouncing = false
			$Tween.stop(self)
			$Tween.interpolate_property(
				self, "speed", self.speed, 100, self.bounce_duration, $Tween.TRANS_LINEAR, $Tween.EASE_IN_OUT
			)
			$Tween.start()
			yield($Tween, "tween_completed")
			self.done_bouncing = true
			self.bounce_direction = null

func move(velocity, delta):
	var collision_info = self.move_and_collide(velocity * delta)
	if collision_info:
		if collision_info.collider is KinematicBody2D:  # Clash between players
			var self_factor = 1
			var collider_factor = 1
			match [self.state, collision_info.collider.state]:
				[DASH, DASH]:
					pass
				[DASH, _]:
					collider_factor = self.dashed_factor
				[_, DASH]:
					self_factor = self.dashed_factor
			self.on_push(collision_info.collider_velocity.length(), velocity.bounce(collision_info.normal).normalized(), self_factor)
			collision_info.collider.on_push((collision_info.remainder / delta).length(), -collision_info.normal, collider_factor)
		else:
			self.bounce_direction = velocity.bounce(collision_info.normal).normalized()
	return collision_info

func on_push(speed, direction, factor=1):
	$Tween.stop(self)
	self.bounce_direction = direction
	self.speed = speed * factor
	self.state = IDLE  # HACK: prevents eternal bounces
