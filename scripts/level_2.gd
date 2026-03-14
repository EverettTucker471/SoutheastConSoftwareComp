extends Node2D

@onready var win_screen: CanvasLayer = $WinScreen

var _is_game_won: bool = false

func _ready() -> void:
	# Hide the win screen initially when the level loads
	if win_screen:
		win_screen.visible = false
	
	# Find the Boss node and connect to its defeat signal
	# (Make sure your boss node is exactly named "Boss" in the level_2 scene!)
	var boss = get_node_or_null("Boss")
	if boss:
		boss.boss_defeated.connect(_on_boss_defeated)
	else:
		push_warning("Level 2: Could not find a node named 'Boss'!")

func _on_boss_defeated() -> void:
	_is_game_won = true
	if win_screen:
		win_screen.visible = true

func _input(event: InputEvent) -> void:
	# If the game is won and the player presses "ui_accept" (usually Space/Enter)
	if _is_game_won and event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/level_0.tscn")
