extends RigidBody2D

signal picked_up

# Upward velocity given to the player when they land on the ball.
const BALL_BOUNCE_BOOST := -650.0

var _has_bounced_player := false

# Immunity state — ball ignores the player until it has fully cleared their body.
var _immune_player: Node2D = null
var _immune_min_timer := 0.0
var _saved_layer: int


func _ready() -> void:
	add_to_group("basketball")
	$PlayerDetector.body_entered.connect(_on_player_detector_body_entered)
	$PlayerDetector.body_exited.connect(_on_player_detector_body_exited)


func launch(impulse: Vector2) -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	apply_central_impulse(impulse)


# Disables all physical + detector interaction until the ball has moved at least
# min_time seconds AND is far enough from the player to be fully clear.
func set_immune(player_body: Node2D, min_time: float = 0.3) -> void:
	_immune_player = player_body
	_immune_min_timer = min_time
	_saved_layer = collision_layer
	# Only clear the layer (so the player's CharacterBody2D sweep can't hit us).
	# Leave collision_mask alone so the ball still resolves against the floor/walls.
	collision_layer = 0
	$PlayerDetector.monitoring = false


func try_pickup() -> void:
	emit_signal("picked_up")
	queue_free()


func _process(delta: float) -> void:
	if _immune_player != null:
		_immune_min_timer -= delta
		if _immune_min_timer <= 0.0:
			# Ball radius ~16 + player capsule radius ~14 + small buffer = ~40
			var dist := global_position.distance_to(_immune_player.global_position)
			if dist > 40.0:
				collision_layer = _saved_layer
				$PlayerDetector.monitoring = true
				_immune_player = null


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
	pass  # Reserved for future use.
