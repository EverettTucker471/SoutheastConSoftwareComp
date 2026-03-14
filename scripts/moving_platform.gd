extends AnimatableBody2D

@export var move_offset: Vector2 = Vector2(200, 0)
@export var move_duration: float = 2.5

var _origin: Vector2


func _ready() -> void:
	_origin = global_position
	_start_motion()


func _start_motion() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", _origin + move_offset, move_duration)
	tween.tween_property(self, "global_position", _origin, move_duration)
	tween.set_loops()
