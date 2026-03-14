extends StaticBody2D

signal wall_broken

var _broken := false

@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _detector_shape: CollisionShape2D = $BallDetector/CollisionShape2D
@onready var _visual: Node2D = $Visual
@onready var _hint: Label = $HintLabel
@onready var _broken_label: Label = $BrokenLabel

@export var wall_size := Vector2(20, 120)
@export var detector_size := Vector2(48, 130)
@export var break_label := "OPEN!"
@export var auto_free := false
@export var reveal_path: NodePath = NodePath()
@export var reveal_delay := 0.0
@export var debug := false


func _ready() -> void:
	add_to_group("breakable_wall")
	_apply_sizes()
	_broken_label.visible = false
	$BallDetector.body_entered.connect(_on_ball_entered)


# Called by the Area2D child when a ball enters it.
func _on_ball_entered(body: Node) -> void:
	if _broken or not body.is_in_group("basketball"):
		return
	if body.power_level == 3:
		if debug:
			print("BreakableWall: red ball detected, breaking.")
		_break(body)
	else:
		if debug:
			print("BreakableWall: ball power_level=", body.power_level)


func _break(ball: Node) -> void:
	_broken = true
	# Disable the physical wall immediately so it can't bounce the ball.
	_shape.set_deferred("disabled", true)
	$BallDetector.set_deferred("monitoring", false)
	# Restore the ball's pre-bounce velocity so it carries full momentum.
	# (The basketball script stores this each physics step.)
	if ball is RigidBody2D:
		ball.linear_velocity = ball._prev_velocity
	_broken_label.text = break_label
	_broken_label.visible = true
	_hint.visible = false
	_visual.visible = false
	add_to_group("wall_broken")
	_trigger_reveal()
	wall_broken.emit()
	if auto_free:
		await get_tree().create_timer(0.4).timeout
		queue_free()
	else:
		await get_tree().create_timer(0.8).timeout
		_broken_label.visible = false


func _trigger_reveal() -> void:
	if reveal_path == NodePath():
		return
	var node := get_node_or_null(reveal_path)
	if node == null:
		return
	if reveal_delay > 0.0:
		await get_tree().create_timer(reveal_delay).timeout
	_reveal_node_recursive(node)


func _reveal_node_recursive(node: Node) -> void:
	if node is CanvasItem:
		(node as CanvasItem).visible = true
	if node is CollisionShape2D:
		(node as CollisionShape2D).disabled = false
	if node is CollisionPolygon2D:
		(node as CollisionPolygon2D).disabled = false
	for child in node.get_children():
		_reveal_node_recursive(child)


func _apply_sizes() -> void:
	if _shape.shape == null or not (_shape.shape is RectangleShape2D):
		_shape.shape = RectangleShape2D.new()
	if _detector_shape.shape == null or not (_detector_shape.shape is RectangleShape2D):
		_detector_shape.shape = RectangleShape2D.new()
	(_shape.shape as RectangleShape2D).size = wall_size
	(_detector_shape.shape as RectangleShape2D).size = detector_size
