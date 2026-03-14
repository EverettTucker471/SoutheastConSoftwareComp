extends Area2D

@export var damage: int = 1
@export var cooldown: float = 0.8

var _cooling_down := false


func _ready() -> void:
	# Only detect the player layer.
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _cooling_down:
		return
	if not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		_cooling_down = true
		await get_tree().create_timer(cooldown).timeout
		_cooling_down = false
