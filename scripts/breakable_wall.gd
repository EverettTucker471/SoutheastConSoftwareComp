extends StaticBody2D

var _broken := false

@onready var _shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("breakable_wall")
	$BallDetector.body_entered.connect(_on_ball_entered)


# Called by the Area2D child when a ball enters it.
func _on_ball_entered(body: Node) -> void:
	if _broken or not body.is_in_group("basketball"):
		return
	if body.power_level == 3:
		_broken = true
		# Disable the physical wall immediately so it can't bounce the ball.
		_shape.set_deferred("disabled", true)
		# Restore the ball's pre-bounce velocity so it carries full momentum.
		body.linear_velocity = body._prev_velocity
		queue_free()
