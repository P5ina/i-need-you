class_name VultureThoughts
extends CanvasLayer

@export var thoughts: Array[String]
@export var fade_duration: float = 0.2

@onready var left_mouse_button: HBoxContainer = $LeftMouseButton
@onready var right_mouse_button: HBoxContainer = $RightMouseButton
@onready var left_action_label: Label = $LeftMouseButton/LeftActionLabel
@onready var right_action_label: Label = $RightMouseButton/RightActionLabel


func _ready() -> void:
	left_mouse_button.modulate.a = 0
	right_mouse_button.modulate.a = 0


func show_hint(step: VerticalMovement.Step) -> void:
	if step == VerticalMovement.Step.LEFT_STEP:
		left_action_label.text = thoughts.pick_random()
		var tween: Tween = create_tween()
		tween.tween_property(left_mouse_button, "modulate:a", 1.0, fade_duration)
	else:
		right_action_label.text = thoughts.pick_random()
		var tween: Tween = create_tween()
		tween.tween_property(right_mouse_button, "modulate:a", 1.0, fade_duration)


func hide_hint() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(left_mouse_button, "modulate:a", 0.0, fade_duration)
	tween.parallel().tween_property(right_mouse_button, "modulate:a", 0.0, fade_duration)
