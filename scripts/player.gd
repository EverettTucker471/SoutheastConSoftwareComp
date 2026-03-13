extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -500.0
const GRAVITY := 980.0

# Assign this in the Inspector after creating the Basketball scene.
@export var basketball_scene: PackedScene

@onready var shoot_point: Marker2D = $ShootPoint
@onready var sprite: Sprite2D = $Sprite2D

var facing_right := true
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
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = dir * SPEED
		facing_right = dir > 0
		sprite.flip_h = not facing_right
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8)


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

	# Slight upward arc so the ball has height to bounce with.
	var dir := Vector2(1.0 if facing_right else -1.0, -0.25).normalized()
	ball.launch(dir * 680.0)

	_can_shoot = false
	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	_can_shoot = true


# Called by the Basketball when the player lands on it.
func bounce_off_ball(boost: float) -> void:
	velocity.y = boost
