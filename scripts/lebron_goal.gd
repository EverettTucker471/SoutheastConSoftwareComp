extends Area2D

# We emit this signal when the player touches the box
signal player_reached_goal

func _ready() -> void:
	# Connect the built-in Area2D signal to our custom function
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the object entering is the player
	if body.is_in_group("player"):
		player_reached_goal.emit()
