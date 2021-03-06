extends KinematicBody2D

enum State {IDLE, ACCELERATE, DECELERATE}
export var player_idx = 0
export var max_speed = 500
export var acceleration = 75
export var deceleration = 0.1
var state = IDLE
var velocity = Vector2()
var input_direction = Vector2()


func _process(delta):
	if input_direction:
		$CircleArrowPivot.rotation_degrees = input_direction.angle() * (180 / PI)

func _physics_process(delta):
	st_machine(get_input_direction())

func get_input_direction():
	if len(Input.get_connected_joypads()) > player_idx:
		input_direction = Vector2(
			Input.get_joy_axis(player_idx, JOY_AXIS_0),
			Input.get_joy_axis(player_idx, JOY_AXIS_1)
		)
		if input_direction.length() < 0.2:
			input_direction = Vector2()
	else:
		input_direction.x = (
			float(Input.is_action_pressed("player_%d_move_right" % player_idx)) -
			float(Input.is_action_pressed("player_%d_move_left" % player_idx))
		)
		input_direction.y = (
			float(Input.is_action_pressed("player_%d_move_down" % player_idx)) -
			float(Input.is_action_pressed("player_%d_move_up" % player_idx))
		)
	return input_direction.clamped(1)

func st_machine(input_direction):
	match state:
		IDLE:
			if input_direction:
				state = ACCELERATE
		ACCELERATE:
			velocity = (velocity + (acceleration * input_direction)).clamped(max_speed)
			move_and_slide(velocity)
			if not input_direction:
				state = DECELERATE
		DECELERATE:
			# Clamp on max_speed * input ?
			# var signs = Vector2(sign(velocity.x), sign(velocity.y))
			# velocity = (velocity.abs() - Vector2(deceleration, deceleration)) * signs
			velocity *= deceleration
			move_and_slide(velocity)
			if input_direction:
				state = ACCELERATE
