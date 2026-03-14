extends CharacterBody2D

@export var max_health: float = 100.0
# A multiplier to scale the raw velocity number into a reasonable damage value
@export var damage_multiplier: float = 0.05 

var current_health: float

@onready var hitbox: Area2D = $BossHitbox

func _ready() -> void:
	current_health = max_health
	# Connect the hitbox signal so we know when something touches the boss
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body: Node2D) -> void:
	# 1. Identify if the object hitting us is the basketball.
	# We use the same script path check you used in the hoop!
	if body.get_script() != null and body.get_script().resource_path == "res://scripts/basketball.gd":
		
		# 2. Grab the ball's velocity and calculate its speed (magnitude)
		# We have to cast the body to RigidBody2D to access linear_velocity
		var ball = body as RigidBody2D
		var impact_speed = ball.linear_velocity.length()
		
		# 3. Calculate and apply the damage
		var damage = impact_speed * damage_multiplier
		
		# Optional: Ignore tiny taps to prevent taking 0.01 damage
		if damage > 1.0: 
			take_damage(damage)

func take_damage(amount: float) -> void:
	current_health -= amount
	print("Boss took ", snapped(amount, 0.1), " damage! Health remaining: ", snapped(current_health, 0.1))
	
	# Add flash effects, play hurt sounds, or update health bars here!
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Boss Defeated!")
	queue_free() # Removes the boss from the scene
