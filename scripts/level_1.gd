extends Node2D

var _won := false
# Grabbing the next scene to transition to
@export_file("*.tscn") var next_scene_path: String


func _ready() -> void:
	$GoalArea.body_entered.connect(_on_goal_reached)
	$WinScreen.visible = false


func _on_goal_reached(body: Node) -> void:
	if body.is_in_group("player") and not _won:
		_won = true
		if next_scene_path != "":
			print("Transitioning to: ", next_scene_path)
			get_tree().change_scene_to_file(next_scene_path)
		else:
			push_warning("No next scene path set for this transition zone!")
