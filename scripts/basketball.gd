extends RigidBody2D

# How long the ball lives before disappearing.
const LIFETIME := 7.0
# Upward velocity given to the player when they land on the ball.
const BALL_BOUNCE_BOOST := -650.0

var _elapsed := 0.0
var _has_bounced_player := false   # prevent double-triggering per touch


func _ready() -> void:
	$PlayerDetector.body_entered.connect(_on_player_detector_body_entered)


func launch(impulse: Vector2) -> void:
	# Reset in case the ball is reused (not strictly needed but safe).
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	apply_central_impulse(impulse)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= LIFETIME:
		queue_free()


# Fade the ball out slightly as it ages so the player has a visual cue.
func _physics_process(_delta: float) -> void:
	var life_ratio := _elapsed / LIFETIME
	modulate.a = clamp(1.0 - life_ratio * 0.6, 0.4, 1.0)


func _on_player_detector_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	# Only trigger if the player is falling onto the ball (moving downward).
	if body.velocity.y > 50.0 and not _has_bounced_player:
		_has_bounced_player = true
		body.bounce_off_ball(BALL_BOUNCE_BOOST)
		# Dampen the ball so it doesn't fly off wildly after the boost.
		linear_velocity *= 0.25
		# Reset the flag after a short delay so repeated bounces work.
		await get_tree().create_timer(0.3).timeout
		_has_bounced_player = false
