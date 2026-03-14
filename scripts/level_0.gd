extends Node2D

@export var level_title: String = "WORLD 1-1  |  SKYLINE RUN"
@export var hint_primary: String = "Chain platforms, avoid spikes, and grab tokens."
@export var hint_secondary: String = "Score a basket at the far end to exit."
@export var time_limit: float = 120.0
@export var camera_limit_right: int = 4000
@export var camera_limit_bottom: int = 720
@export var start_score: int = 0

@onready var _score_label: Label = get_node_or_null("HUD/ScoreLabel")
@onready var _timer_label: Label = get_node_or_null("HUD/TimerLabel")
@onready var _title_label: Label = get_node_or_null("HUD/LevelTitle")
@onready var _hint_primary_label: Label = get_node_or_null("HUD/HintShoot")
@onready var _hint_secondary_label: Label = get_node_or_null("HUD/HintGoal")
@onready var _player: Node = get_node_or_null("Player")

var _time_left: float
var _score: int = 0
var _ended := false


func _ready() -> void:
	_score = start_score
	_time_left = time_limit
	_update_labels()
	_update_ui()
	if _player != null and _player.has_method("set_camera_limits"):
		_player.set_camera_limits(0, 0, camera_limit_right, camera_limit_bottom)


func _process(delta: float) -> void:
	if _ended:
		return
	_time_left = max(_time_left - delta, 0.0)
	_update_timer()
	if _time_left <= 0.0:
		_end_run()


func add_score(amount: int) -> void:
	if _ended:
		return
	_score += amount
	_update_ui()


func add_time(seconds: float) -> void:
	if _ended:
		return
	_time_left += seconds
	_update_timer()


func _end_run() -> void:
	_ended = true
	if _player != null and _player.has_method("take_damage"):
		_player.take_damage(999)


func _update_ui() -> void:
	if _score_label != null:
		_score_label.text = "Score: %d" % _score
	_update_timer()


func _update_timer() -> void:
	if _timer_label == null:
		return
	var seconds_left := int(ceil(_time_left))
	_timer_label.text = "Time: %d" % seconds_left


func _update_labels() -> void:
	if _title_label != null:
		_title_label.text = level_title
	if _hint_primary_label != null:
		_hint_primary_label.text = hint_primary
	if _hint_secondary_label != null:
		_hint_secondary_label.text = hint_secondary
