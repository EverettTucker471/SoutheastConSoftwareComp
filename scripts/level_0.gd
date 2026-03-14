extends Node2D

@onready var start_screen: CanvasLayer = $StartScreen

func _ready() -> void:
	# 1. Make sure the screen is visible when the scene loads
	if start_screen:
		start_screen.visible = true
	
	# 2. Pause the entire game world (physics, animations, etc.)
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	# 3. Listen for the spacebar, but ONLY if the start screen is currently showing
	if start_screen.visible and event.is_action_pressed("ui_accept"):
		
		# Hide the UI
		start_screen.visible = false
		
		# Unpause the game world to start the action
		get_tree().paused = false
		
		# Tell Godot we handled this input so the player doesn't instantly jump
		get_viewport().set_input_as_handled()
