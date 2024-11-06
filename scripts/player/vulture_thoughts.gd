class_name VultureThoughts
extends CanvasLayer

@export var first_thoughts: Array[String]
@export var thoughts: Array[String]
@export var fade_in_duration: float = 0.2
@export var fade_out_duration: float = 0.8
@export var hint_distance: float = -50

var active_instance: Control
var active_is_backwards: bool

@onready var left_mouse_button_scene: PackedScene = preload("res://scenes/stories/vulture/left_mouse_button_thought.tscn")
@onready var right_mouse_button_scene: PackedScene = preload("res://scenes/stories/vulture/right_mouse_button_thought.tscn")


func show_hint(step: VerticalMovement.Step, backwards: bool) -> void:
	if step == VerticalMovement.Step.LEFT_STEP:
		var left_mouse_button_instance: Control = left_mouse_button_scene.instantiate()
		left_mouse_button_instance.modulate.a = 0
		add_child(left_mouse_button_instance)
		active_instance = left_mouse_button_instance
		active_is_backwards = backwards
		left_mouse_button_instance.get_node("LeftActionLabel").text = first_thoughts.pick_random() if not backwards else thoughts.pick_random()
		var tween: Tween = create_tween()
		tween.tween_property(left_mouse_button_instance, "modulate:a", 1.0, fade_in_duration).from(0.0)
	else:
		var right_mouse_button_instance: Control = right_mouse_button_scene.instantiate()
		right_mouse_button_instance.modulate.a = 0
		add_child(right_mouse_button_instance)
		active_instance = right_mouse_button_instance
		active_is_backwards = backwards
		right_mouse_button_instance.get_node("RightActionLabel").text = first_thoughts.pick_random() if not backwards else thoughts.pick_random()
		var tween: Tween = create_tween()
		tween.tween_property(right_mouse_button_instance, "modulate:a", 1.0, fade_in_duration).from(0.0)


func send_hint() -> void:
	if not active_instance:
		return
	var tween: Tween = create_tween()
	var direction: float = -1 if active_is_backwards else 1
	tween.tween_property(active_instance, "position:y", hint_distance * direction, fade_out_duration).as_relative()
	tween.parallel().tween_property(active_instance, "modulate:a", 0.0, fade_out_duration)


func hide_hint() -> void:
	if not active_instance:
		return
	var tween: Tween = create_tween()
	tween.tween_property(active_instance, "modulate:a", 0.0, fade_out_duration)
