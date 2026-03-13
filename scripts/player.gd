extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -500.0
const GRAVITY := 980.0

# Assign this in the Inspector after creating the Basketball scene.
@export var basketball_scene: PackedScene

@onready var shoot_point: Marker2D = $ShootPoint
@onready var sprite: Sprite2D = $Sprite2D

var last_direction := Vector2(1.0, 0.0)  # Track the direction the player is moving (8 directions)
var _can_shoot := true
const SHOOT_COOLDOWN := 0.8


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func _handle_movement() -> void:
	var dir_x := Input.get_axis("move_left", "move_right")
	var dir_y := Input.get_axis("move_up", "move_down")
	
	if dir_x != 0:
		velocity.x = dir_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8)
	
	# Update sprite flip based on horizontal direction only
	if dir_x != 0:
		sprite.flip_h = dir_x < 0
	
	# Track the last movement direction (8 directions) for shooting
	var movement := Vector2(dir_x, dir_y)
	if movement.length() > 0:
		last_direction = movement.normalized()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and not event.is_echo() and _can_shoot:
		_shoot_basketball()


func _shoot_basketball() -> void:
	if basketball_scene == null:
		push_warning("Player: basketball_scene is not assigned!")
		return

	var ball: Node2D = basketball_scene.instantiate()
	# Add to current scene so the ball is not destroyed with the player.
	get_tree().current_scene.add_child(ball)
	ball.global_position = shoot_point.global_position

	# Shoot in the direction the player is moving (8 directions)
	var shoot_dir := last_direction * 680.0
	ball.launch(shoot_dir)

	_can_shoot = false
	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	_can_shoot = true


# Called by the Basketball when the player lands on it.
func bounce_off_ball(boost: float) -> void:
	velocity.y = boost
