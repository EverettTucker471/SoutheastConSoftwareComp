extends Node2D

@onready var win_screen: CanvasLayer = $WinScreen

var _is_game_won: bool = false
var _is_boss_dead: bool = false

func _ready() -> void:
	# Hide the win screen initially
	if win_screen:
		win_screen.visible = false
	
	# 1. Connect the Boss defeat signal
	var boss = get_node_or_null("Boss")
	if boss:
		boss.boss_defeated.connect(_on_boss_defeated)
	else:
		push_warning("Level 2: Could not find the Boss node!")
		
	# 2. Connect the LeBron Goal signal
	# Update this path if you place LebronGoal inside a "World" node or similar
	var lebron = get_node_or_null("LebronGoal") 
	if lebron:
		lebron.player_reached_goal.connect(_on_lebron_reached)
	else:
		push_warning("Level 2: Could not find the LebronGoal node!")

func _on_boss_defeated() -> void:
	_is_boss_dead = true
	print("Boss defeated! The goal is now open!")
	
	# Optional: You could add a visual cue here, like changing LeBron's 
	# modulate color from semi-transparent to fully opaque, or playing a sound!

func _on_lebron_reached() -> void:
	# Only trigger the win if the boss is actually dead!
	if _is_boss_dead and not _is_game_won:
		_is_game_won = true
		if win_screen:
			win_screen.visible = true

func _input(event: InputEvent) -> void:
	# Restart the game if they won and press the accept button
	if _is_game_won and event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/level_0.tscn")
