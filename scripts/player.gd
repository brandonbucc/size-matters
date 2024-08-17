extends CharacterBody2D

const ACCELERATION = 3000
const FRICTION = 3000
const JUMP_HEIGHT = -600
const MAX_SPEED = 400

var can_dash = true
var dash = 1500
var direction = 1
var jump_buffered = false
var wall_jump = 500

func _physics_process(delta):
	var input = Input.get_axis("left","right")
	if input != 0:
		velocity = velocity.move_toward(Vector2(input * MAX_SPEED, velocity.y), ACCELERATION * delta)
		direction = input
	else:
		velocity = velocity.move_toward(Vector2(0, velocity.y), FRICTION * delta)
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	var was_on_floor = is_on_floor()
	if Input.is_action_just_pressed("jump") && (is_on_floor() || !$CoyoteTime.is_stopped()):
		velocity.y = JUMP_HEIGHT
	elif Input.is_action_just_pressed("jump") && !is_on_floor():
		jump_buffered = true
		$JumpBuffer.start()
	if jump_buffered && is_on_floor() && !$JumpBuffer.is_stopped():
		velocity.y = JUMP_HEIGHT
		jump_buffered = false
	if Input.is_action_just_pressed("dash") && can_dash:
		velocity.x = dash
		$DashCooldown.start()
	if !$DashCooldown.is_stopped():
		can_dash = false
	else:
		can_dash = true
	if direction < 0:
		dash = -1000
	else:
		dash = 1000
	if is_on_wall() && Input.is_action_just_pressed("jump") && Input.is_action_just_pressed("right"):
		velocity.y = JUMP_HEIGHT
		velocity.x = -wall_jump
	if is_on_wall() && Input.is_action_just_pressed("jump") && Input.is_action_just_pressed("left"):
		velocity.y = JUMP_HEIGHT
		velocity.x = wall_jump
	move_and_slide()
	if was_on_floor && !is_on_floor():
		$CoyoteTime.start()
