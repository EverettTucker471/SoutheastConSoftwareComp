extends Node2D

var _won := false


func _ready() -> void:
	$GoalArea.body_entered.connect(_on_goal_reached)
	$WinScreen.visible = false


func _on_goal_reached(body: Node) -> void:
	if body.is_in_group("player") and not _won:
		_won = true
		$WinScreen.visible = true
