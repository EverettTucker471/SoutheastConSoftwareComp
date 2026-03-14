extends Area2D

# Emitted when the player enters the hoop.
signal level_complete

# Path to the next level — leave empty to just show the complete screen.
@export var next_level: String = ""
# Optional node path to an elevator pad to trigger instead of transitioning.
@export var elevator_pad_path: NodePath = NodePath()
@export var score_reward: int = 50
@export var time_bonus: float = 10.0

var elevator_pad: Node2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Resolve the NodePath to an actual node reference
	if elevator_pad_path != NodePath():
		elevator_pad = get_node(elevator_pad_path)


func _on_body_entered(body: Node) -> void:
	# Only trigger for the basketball (RigidBody2D from basketball.tscn)
	if body.get_script() == null or body.get_script().resource_path != "res://scripts/basketball.gd":
		return

	print("=== BASKETBALL IN HOOP! ===")
	emit_signal("level_complete")
	var level := get_tree().current_scene
	if level != null and level.has_method("add_score"):
		level.add_score(score_reward)
	if time_bonus > 0.0 and level != null and level.has_method("add_time"):
		level.add_time(time_bonus)

	# If there's an elevator pad, trigger it instead of transitioning levels.
	if elevator_pad != null:
		await get_tree().create_timer(0.5).timeout  # Wait for ball to settle
		elevator_pad.rise_up()
		return

	# Freeze the game brawiefly, then transition.
	get_tree().paused = true
	await get_tree().create_timer(1.5, true).timeout
	get_tree().paused = false

	if next_level != "":
		get_tree().change_scene_to_file(next_level)
	else:
		# Reload current level (for jam purposes — swap for a real end screen later).
		get_tree().reload_current_scene()
