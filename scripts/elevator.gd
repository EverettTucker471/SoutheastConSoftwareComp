extends AnimatableBody2D

# Export variables so you can tweak the elevator's behavior right in the Inspector
@export var move_offset: Vector2 = Vector2(0, -800) # Moves up 800 pixels to the top of the screen
@export var move_duration: float = 2.0

@onready var trigger_plate: Area2D = $TriggerPlate

var is_moving: bool = false
var original_position: Vector2

func _ready() -> void:
	original_position = global_position
	# Connect the body_entered signal from the TriggerPlate through code
	trigger_plate.body_entered.connect(_on_trigger_plate_body_entered)

func _on_trigger_plate_body_entered(body: Node2D) -> void:
	# Check if the object entering the area is the ball.
	# Adjust "Ball" to match your ball node's exact name or use groups.
	if body.name == "Ball" or body.is_in_group("ball"):
		if not is_moving:
			rise_up()

func rise_up() -> void:
	is_moving = true
	
	# Create a tween to animate the position
	var tween = create_tween()
	
	# Make the movement smooth (ease in and out)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	var target_position = original_position + move_offset
	
	# Animate the position property over the duration
	tween.tween_property(self, "global_position", target_position, move_duration)
	
	# OPTIONAL: Uncomment the lines below if you want the elevator to return to the bottom after waiting 2 seconds
	# tween.tween_interval(2.0)
	# tween.tween_property(self, "global_position", original_position, move_duration)
	# tween.tween_callback(func(): is_moving = false)
