extends CharacterBody2D

const ACCELERATION = 3000
const FRICTION = 3000
const JUMP_CANCEL = 14000
const JUMP_HEIGHT = -600
const MAX_SPEED = 400

enum {DASH, MOVEMENT, WALL}

var can_dash = true
var dash_speed = 900
var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_buffered = false
var state = MOVEMENT
var wall_jump = 600
var wall_slide = 750

func _physics_process(delta):
	match state:
		DASH:
			dash()
		MOVEMENT:
			movement(delta)
		WALL:
			wall(delta)

func movement(delta):
	var input = Input.get_axis("left", "right")
	if input != 0:
		velocity = velocity.move_toward(Vector2(input * MAX_SPEED, velocity.y), ACCELERATION * delta)
		direction = input
	else:
		velocity = velocity.move_toward(Vector2(0, velocity.y), FRICTION * delta)
	velocity.y += gravity * delta
	var was_on_floor = is_on_floor()
	if Input.is_action_just_pressed("jump") && (is_on_floor() || !$CoyoteTime.is_stopped()):
		velocity.y = JUMP_HEIGHT
	elif Input.is_action_just_pressed("jump") && !is_on_floor():
		jump_buffered = true
		$JumpBuffer.start()
	if jump_buffered && is_on_floor() && !$JumpBuffer.is_stopped():
		velocity.y = JUMP_HEIGHT
		jump_buffered = false
	if Input.is_action_just_released("jump") && velocity.y < 0:
		velocity = velocity.move_toward(Vector2(velocity.x, 0), JUMP_CANCEL * delta)
	if Input.is_action_just_pressed("dash") && can_dash:
		$DashCooldown.start()
		$DashTime.start()
		state = DASH
	if !$DashCooldown.is_stopped():
		can_dash = false
	else:
		can_dash = true
	if direction < 0:
		dash_speed = -900
	else:
		dash_speed = 900
	move_and_slide()
	if on_wall() && !is_on_floor():
		$DashCooldown.stop()
		velocity = Vector2.ZERO
		state = WALL
	if was_on_floor && !is_on_floor():
		$CoyoteTime.start()
	var up_down = Input.get_axis("up", "down")
	if up_down != 0:
		$Camera2D.drag_vertical_offset = up_down * 2
	else:
		$Camera2D.drag_vertical_offset = 0

func on_wall():
	return left_wall() || right_wall()

func left_wall():
	return $Left.is_colliding()

func right_wall():
	return $Right.is_colliding()

func wall(delta):
	var input = Input.get_axis("left", "right")
	if input != 0:
		velocity = velocity.move_toward(Vector2(input * MAX_SPEED, velocity.y), ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2(0, velocity.y), FRICTION * delta)
	velocity.y += wall_slide * delta
	if left_wall():
		dash_speed = 900
		wall_jump = 600
	elif right_wall():
		dash_speed = -900
		wall_jump = -600
	if Input.is_action_just_released("jump") && velocity < Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, JUMP_CANCEL * delta)
	if Input.is_action_just_pressed("dash") && can_dash:
		$DashCooldown.start()
		$DashTime.start()
		state = DASH
	if !$DashCooldown.is_stopped():
		can_dash = false
	else:
		can_dash = true
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_HEIGHT
		velocity.x = wall_jump
	move_and_slide()
	if !on_wall() || is_on_floor():
		state = MOVEMENT

func dash():
	velocity.x = dash_speed
	velocity.y = 0
	if $DashTime.is_stopped() && on_wall():
		state = WALL
	elif $DashTime.is_stopped():
		state = MOVEMENT
	move_and_slide()
