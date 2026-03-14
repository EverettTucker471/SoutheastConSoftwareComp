extends CharacterBody2D

signal boss_defeated

@export var max_health: float = 100.0
@export var damage_multiplier: float = 0.05 

# Movement Variables
@export var SPEED: float = 150.0
@export var JUMP_VELOCITY: float = -500.0

var current_health: float

# AI Decision Timers
var _ai_decision_timer: float = 0.0
var _jump_decision_timer: float = 0.0
var _move_direction: float = 0.0

# Get the default gravity from project settings
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var hitbox: Area2D = $BossHitbox

func _ready() -> void:
	current_health = max_health
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	# Initialize the timers so the boss doesn't instantly move on frame 1
	_ai_decision_timer = randf_range(0.5, 1.5)
	_jump_decision_timer = randf_range(1.0, 3.0)

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Run the AI logic to determine direction and jumping
	_handle_ai(delta)

	# 3. Apply Horizontal Movement
	if _move_direction != 0:
		velocity.x = _move_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Move the body and handle collisions with the world
	move_and_slide()

func _handle_ai(delta: float) -> void:
	_ai_decision_timer -= delta
	_jump_decision_timer -= delta

	# --- HORIZONTAL MOVEMENT DECISION ---
	if _ai_decision_timer <= 0.0:
		# Reset the timer to make a new decision in 1 to 2.5 seconds
		_ai_decision_timer = randf_range(1.0, 2.5)
		
		# Look for the player
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			
			# 80% chance to chase the player, 20% chance to wander/stop randomly
			if randf() < 0.8:
				# sign() returns 1 if player is right, -1 if left, 0 if perfectly aligned
				_move_direction = sign(player.global_position.x - global_position.x)
			else:
				_move_direction = [-1, 0, 1].pick_random()
		else:
			# If the player is missing (e.g., dead), just wander randomly
			_move_direction = [-1, 0, 1].pick_random()

	# --- JUMPING DECISION ---
	if is_on_floor():
		# Jump randomly if the timer is up
		if _jump_decision_timer <= 0.0:
			_jump_decision_timer = randf_range(2.0, 5.0) # Set next jump check
			if randf() < 0.5: # 50% chance to actually jump when the timer hits
				velocity.y = JUMP_VELOCITY
		
		# EMERGENCY JUMP: If the boss is running into a wall, jump automatically to get over it
		if is_on_wall() and _move_direction != 0:
			velocity.y = JUMP_VELOCITY

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1)
		return
	if body.get_script() != null and body.get_script().resource_path == "res://scripts/basketball.gd":
		var ball = body as RigidBody2D
		var impact_speed = ball.linear_velocity.length()
		var damage = impact_speed * damage_multiplier
		
		if damage > 1.0: 
			take_damage(damage)

func take_damage(amount: float) -> void:
	current_health -= amount
	print("Boss took ", snapped(amount, 0.1), " damage! Health remaining: ", snapped(current_health, 0.1))
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Boss Defeated!")
	boss_defeated.emit()
	queue_free()
