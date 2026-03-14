extends Area2D

@export var value: int = 5
@export var heal_amount: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if heal_amount > 0 and body.has_method("heal"):
		body.heal(heal_amount)
	var level := get_tree().current_scene
	if level != null and level.has_method("add_score"):
		level.add_score(value)
	queue_free()
