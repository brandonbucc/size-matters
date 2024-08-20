extends CharacterBody2D

const JUMP_CANCEL = 14000
const SIZE_CHANGE = 5

enum {DASH, MOVEMENT, WALL}
enum {SMALL, NORMAL, LARGE}

@onready var tile_map_layer = get_node("/root/Level/TileMapLayer")

var acceleration = 3000
var can_dash = true
var dash_speed = 900
var direction = 1
var friction = 3000
var gravity = 1500
var jump_buffered = false
var jump_height = -600
var max_speed = 400
var size = NORMAL
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
	change_size()
	reset()

func movement(delta):
	var input = Input.get_axis("left", "right")
	if size == SMALL:
		max_speed = 650
		acceleration = 6000
		friction = 6000
		gravity = 1000
		jump_height = -450
		if $Camera2D.zoom != Vector2.ONE * 1.5:
			$Camera2D.zoom = lerp($Camera2D.zoom, Vector2.ONE * 1.5, SIZE_CHANGE * delta)
	if size == NORMAL:
		max_speed = 400
		acceleration = 3000
		friction = 3000
		gravity = 1500
		jump_height = -600
		if $Camera2D.zoom != Vector2.ONE:
			$Camera2D.zoom = lerp($Camera2D.zoom, Vector2.ONE, SIZE_CHANGE * delta)
	if size == LARGE:
		max_speed = 250
		acceleration = 2000
		friction = 2000
		gravity = 2000
		jump_height = -750
		if $Camera2D.zoom != Vector2.ONE / 1.5:
			$Camera2D.zoom = lerp($Camera2D.zoom, Vector2.ONE / 1.5, SIZE_CHANGE * delta)
	if input != 0:
		velocity = velocity.move_toward(Vector2(input * max_speed, velocity.y), acceleration * delta)
		direction = input
	else:
		velocity = velocity.move_toward(Vector2(0, velocity.y), friction * delta)
	velocity.y += gravity * delta
	var was_on_floor = is_on_floor()
	if Input.is_action_just_pressed("jump") && (is_on_floor() || !$CoyoteTime.is_stopped()):
		velocity.y = jump_height
	elif Input.is_action_just_pressed("jump") && !is_on_floor():
		jump_buffered = true
		$JumpBuffer.start()
	if jump_buffered && is_on_floor() && !$JumpBuffer.is_stopped():
		velocity.y = jump_height
		jump_buffered = false
	if Input.is_action_just_released("jump") && velocity.y < 0:
		velocity = velocity.move_toward(Vector2(velocity.x, 0), JUMP_CANCEL * delta)
	if Input.is_action_just_pressed("dash") && can_dash && size == NORMAL:
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
	if on_wall() && !is_on_floor() && size != LARGE:
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
		velocity = velocity.move_toward(Vector2(input * max_speed, velocity.y), acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2(0, velocity.y), friction * delta)
	velocity.y += wall_slide * delta
	if left_wall():
		dash_speed = 900
		wall_jump = 600
	elif right_wall():
		dash_speed = -900
		wall_jump = -600
	if Input.is_action_just_released("jump") && velocity < Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, JUMP_CANCEL * delta)
	if Input.is_action_just_pressed("dash") && can_dash && size == NORMAL:
		$DashCooldown.start()
		$DashTime.start()
		state = DASH
	if !$DashCooldown.is_stopped():
		can_dash = false
	else:
		can_dash = true
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_height
		velocity.x = wall_jump
	move_and_slide()
	if !on_wall() || is_on_floor():
		state = MOVEMENT

func dash():
	velocity.x = dash_speed
	velocity.y = 0
	if $DashTime.is_stopped() && on_wall() && size != LARGE:
		state = WALL
	elif $DashTime.is_stopped():
		state = MOVEMENT
	move_and_slide()

func change_size():
	if Input.is_action_just_pressed("small") && $SizeCooldown.is_stopped():
		scale = Vector2(0.49, 0.49)
		size = SMALL
		$SizeCooldown.start()
	if Input.is_action_just_pressed("normal") && $SizeCooldown.is_stopped():
		scale = Vector2(0.99, 0.99)
		size = NORMAL
		$SizeCooldown.start()
	if Input.is_action_just_pressed("large") && $SizeCooldown.is_stopped():
		scale = Vector2(1.99, 1.99)
		size = LARGE
		$SizeCooldown.start()

func reset():
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _on_finish_body_entered(_body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/end.tscn")
