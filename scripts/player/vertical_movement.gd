class_name VerticalMovement
extends Node

const META_NAME = &"VerticalMovement"

@export var step_distance: float = 20.0
@export var step_duration: float = 0.5
@export var step_cooldown: float = 0.2
@export var step_hint_cooldown: float = 1.5
@onready var body: AnimatableBody2D = owner

@onready var vulture_thoughts: VultureThoughts = $VultureThoughts
@onready var animation: PlayerVultureAnimation = owner.get_meta(PlayerVultureAnimation.META_NAME)

enum Step {
	LEFT_STEP,
	RIGHT_STEP
}

var direction: Vector2 = Vector2.UP
var _next_step: Step = Step.LEFT_STEP
var _can_take_next_step: bool = false
var _tween: Tween

var movement_locked: bool:
	set(value):
		movement_locked = value
		if value:
			vulture_thoughts.hide_hint()
		else:
			show_hint_with_cooldown()


func _ready() -> void:
	owner.set_meta(META_NAME, self)
	show_hint_with_cooldown()


func show_hint_with_cooldown() -> void:
	_tween = create_tween()
	_tween.tween_interval(step_hint_cooldown)
	_tween.tween_callback(_step_done)


func _unhandled_input(event: InputEvent) -> void:
	if not _can_take_next_step or movement_locked:
		return
	if event.is_action_pressed("vulture_leg_left"):
		if _next_step == Step.LEFT_STEP:
			_next_step = Step.RIGHT_STEP
			_make_step()
	if event.is_action_pressed("vulture_leg_right"):
		if _next_step == Step.RIGHT_STEP:
			_next_step = Step.LEFT_STEP
			_make_step()

func _make_step() -> void:
	if _tween:
		_tween.kill()
	_can_take_next_step = false
	vulture_thoughts.hide_hint()
	var animation_direction: PlayerVultureAnimation.AnimationDirection = PlayerVultureAnimation.AnimationDirection.UP if direction == Vector2.UP else PlayerVultureAnimation.AnimationDirection.DOWN
	animation.play_step_animation(animation_direction, _next_step == Step.RIGHT_STEP)
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD) \
		.tween_property(body, "position", direction * step_distance, step_duration) \
		.as_relative()
	_tween.tween_interval(step_cooldown)
	_tween.tween_callback(_step_done)


func _step_done() -> void:
	if movement_locked:
		return
	_can_take_next_step = true
	vulture_thoughts.show_hint(_next_step)
