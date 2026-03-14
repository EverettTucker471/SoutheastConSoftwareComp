extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -500.0
const GRAVITY := 980.0

# Assign this in the Inspector after creating the Basketball scene.
@export var basketball_scene: PackedScene

@onready var shoot_point: Marker2D = $ShootPoint
@onready var sprite: Sprite2D = $Sprite2D
@onready var _ball_indicator: Label = $BallIndicator

var last_direction := Vector2(1.0, 0.0)
var _has_ball := true
var _can_shoot := true
const SHOOT_COOLDOWN := 0.4

# Powershot charge
var _charging := false
var _charge_time := 0.0
const CHARGE_THRESHOLDS := [0.0, 0.3, 0.6, 0.9] # seconds to reach each level
const POWER_SPEEDS := [420.0, 640.0, 900.0, 1400.0]
const POWER_COLORS := [
	Color(0.18, 0.85, 0.18), # green
	Color(0.95, 0.85, 0.08), # yellow
	Color(0.95, 0.48, 0.05), # orange
	Color(0.90, 0.10, 0.10), # red
]


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	move_and_slide()


func _process(delta: float) -> void:
	if _charging:
		_charge_time += delta
		_ball_indicator.modulate = POWER_COLORS[_get_charge_level()]


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

	# Arrow keys set aim direction without moving the player.
	var aim_x := Input.get_axis("aim_left", "aim_right")
	var aim_y := Input.get_axis("aim_up", "aim_down")
	var aim := Vector2(aim_x, aim_y)
	if aim.length() > 0:
		last_direction = aim.normalized()
	elif Vector2(dir_x, dir_y).length() > 0:
		last_direction = Vector2(dir_x, dir_y).normalized()


func _input(event: InputEvent) -> void:
	# Start charging on press.
	if event.is_action_pressed("shoot") and not event.is_echo() and _has_ball and _can_shoot:
		_charging = true
		_charge_time = 0.0
		_ball_indicator.modulate = POWER_COLORS[0]

	# Fire on release.
	if event.is_action_released("shoot") and _charging:
		_charging = false
		_shoot_basketball()

	if event.is_action_pressed("pickup") and not _has_ball:
		_try_pickup()

	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _get_charge_level() -> int:
	for i in range(CHARGE_THRESHOLDS.size() - 1, -1, -1):
		if _charge_time >= CHARGE_THRESHOLDS[i]:
			return i
	return 0


func _try_pickup() -> void:
	for ball in get_tree().get_nodes_in_group("basketball"):
		if global_position.distance_to(ball.global_position) < 50.0:
			ball.picked_up.connect(_on_ball_picked_up)
			ball.try_pickup()
			return


func _shoot_basketball() -> void:
	if basketball_scene == null:
		push_warning("Player: basketball_scene is not assigned!")
		return

	var level := _get_charge_level()

	var ball: Node2D = basketball_scene.instantiate()
	get_tree().current_scene.add_child(ball)
	ball.global_position = shoot_point.global_position
	ball.set_power_level(level)
	ball.launch(last_direction * POWER_SPEEDS[level])
	# While the ball is immune, the player can walk through it.
	# We disable the player's ball-layer mask instead of touching the ball's layer,
	# so Area2D detectors (e.g. breakable wall) can still see the ball.
	set_collision_mask_value(3, false)
	ball.immunity_ended.connect(func(): set_collision_mask_value(3, true), CONNECT_ONE_SHOT)
	ball.set_immune(self , 0.3)
	ball.picked_up.connect(_on_ball_picked_up)

	_has_ball = false
	_ball_indicator.visible = false

	_can_shoot = false
	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	_can_shoot = true


func _on_ball_picked_up() -> void:
	_has_ball = true
	_ball_indicator.visible = true
	_ball_indicator.modulate = POWER_COLORS[0]
	# Safety: restore ball-layer mask in case the ball was freed during immunity.
	set_collision_mask_value(3, true)


# Called by the Basketball when the player lands on it.
func bounce_off_ball(boost: float) -> void:
	velocity.y = boost
