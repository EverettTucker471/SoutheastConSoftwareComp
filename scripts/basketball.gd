extends RigidBody2D

signal picked_up
signal immunity_ended

const BALL_BOUNCE_BOOST := -650.0

# Power level: 0=green (slowest) … 3=red (fastest)
const POWER_COLORS := [
	Color(0.18, 0.85, 0.18), # green
	Color(0.95, 0.85, 0.08), # yellow
	Color(0.95, 0.48, 0.05), # orange
	Color(0.90, 0.10, 0.10), # red
]

var power_level := 0
var _has_bounced_player := false

# Immunity state — ball ignores the player until it has fully cleared their body.
var _immune_player: Node2D = null
var _immune_min_timer := 0.0

# Prevents the same collision from degrading power multiple times in one bounce.
var _collision_cooldown := 0.0
const COLLISION_DEGRADE_COOLDOWN := 0.15

# Saved each physics step so we can restore momentum if a red ball breaks a wall.
var _prev_velocity := Vector2.ZERO


func _ready() -> void:
	add_to_group("basketball")
	$PlayerDetector.body_entered.connect(_on_player_detector_body_entered)
	$PlayerDetector.body_exited.connect(_on_player_detector_body_exited)
	body_entered.connect(_on_body_entered_contact)
	_apply_power_color()


func launch(impulse: Vector2) -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	apply_central_impulse(impulse)


func set_power_level(level: int) -> void:
	power_level = clamp(level, 0, 3)
	# Red ball ignores gravity; all other levels use the default gravity scale.
	gravity_scale = 0.0 if power_level == 3 else 1.4
	_apply_power_color()


func _apply_power_color() -> void:
	$Visual.color = POWER_COLORS[power_level]


# Disables all physical + detector interaction until the ball has moved at least
# min_time seconds AND is far enough from the player to be fully clear.
func set_immune(player_body: Node2D, min_time: float = 0.3) -> void:
	_immune_player = player_body
	_immune_min_timer = min_time
	# Do NOT touch collision_layer — changing it hides the ball from Area2D detectors.
	# The player disables its own ball-layer mask instead (see player.gd).
	$PlayerDetector.monitoring = false


func try_pickup() -> void:
	emit_signal("picked_up")
	queue_free()


func _physics_process(_delta: float) -> void:
	_prev_velocity = linear_velocity


func _process(delta: float) -> void:
	if _collision_cooldown > 0.0:
		_collision_cooldown -= delta

	if _immune_player != null:
		_immune_min_timer -= delta
		if _immune_min_timer <= 0.0:
			# Ball radius ~16 + player capsule radius ~14 + small buffer = ~40
			var dist := global_position.distance_to(_immune_player.global_position)
			if dist > 40.0:
				$PlayerDetector.monitoring = true
				_immune_player = null
				emit_signal("immunity_ended")


func _on_body_entered_contact(body: Node) -> void:
	if body.is_in_group("player") or _immune_player != null:
		return
	# Breakable wall handles its own destruction via its Area2D detector.
	# Normal collision: degrade power level by one step.
	if _collision_cooldown > 0.0 or power_level == 0:
		return
	_collision_cooldown = COLLISION_DEGRADE_COOLDOWN
	set_power_level(power_level - 1)


func _on_player_detector_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	# Falling onto the ball → bounce boost.
	if body.velocity.y > 50.0 and not _has_bounced_player:
		_has_bounced_player = true
		body.bounce_off_ball(BALL_BOUNCE_BOOST)
		linear_velocity *= 0.25
		await get_tree().create_timer(0.3).timeout
		_has_bounced_player = false


func _on_player_detector_body_exited(body: Node) -> void:
	pass # Reserved for future use.
