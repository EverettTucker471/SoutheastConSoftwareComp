extends Area2D

# Emitted when the player enters the hoop.
signal level_complete

# Path to the next level — leave empty to just show the complete screen.
@export var next_level: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	print("=== LEVEL COMPLETE! ===")
	emit_signal("level_complete")

	# Freeze the game briefly, then transition.
	get_tree().paused = true
	await get_tree().create_timer(1.5, true).timeout
	get_tree().paused = false

	if next_level != "":
		get_tree().change_scene_to_file(next_level)
	else:
		# Reload current level (for jam purposes — swap for a real end screen later).
		get_tree().reload_current_scene()
