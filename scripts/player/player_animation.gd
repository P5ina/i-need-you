class_name PlayerAnimation
extends AnimatedSprite2D

const META_NAME = &"AnimationComponent"

enum AnimationDirection {
	UP,
	RIGHT,
	DOWN,
	LEFT,
}

@export var animation_enabled: bool = true

var last_direction: AnimationDirection = AnimationDirection.DOWN
var last_is_moving: bool = false
var last_is_running: bool = false


func _ready() -> void:
	owner.set_meta(META_NAME, self)
	play(direction_to_animation_name(AnimationDirection.DOWN, false, false))


func _process(_delta: float) -> void:
	var normalized_velocity: Vector2 = (owner as CharacterBody2D).velocity.normalized()
	var direction: AnimationDirection = get_direction(normalized_velocity)
	var is_moving: bool = normalized_velocity.length() > 0.1

	if animation_enabled:
		update_animation(direction, is_moving)


func get_direction(normalized_velocity: Vector2) -> AnimationDirection:
	var angle := rad_to_deg(normalized_velocity.angle())
	if not normalized_velocity:
		return last_direction if last_direction != null else AnimationDirection.DOWN
	if angle >= -135 and angle <= -50:
		return AnimationDirection.UP
	elif angle > -50 and angle < 50:
		return AnimationDirection.RIGHT
	elif angle >= 50 and angle <= 135:
		return AnimationDirection.DOWN
	else:
		return AnimationDirection.LEFT


func update_animation(direction: AnimationDirection, is_moving: bool) -> void:
	var is_running: bool = _is_running()
	if direction == last_direction and is_moving == last_is_moving and is_running == last_is_running:
		return

	last_direction = direction
	last_is_moving = is_moving
	last_is_running = is_running
	play(direction_to_animation_name(direction, is_moving, is_running))


func direction_to_animation_name(direction: AnimationDirection, is_moving: bool, is_running: bool) -> String:
	var direction_name: String = ["up", "right", "down", "left"][direction]
	if not is_moving:
		return "idle_" + direction_name
	if is_running:
		var run_name := "run_" + direction_name
		if sprite_frames and sprite_frames.has_animation(run_name):
			return run_name
	return "walk_" + direction_name


func _is_running() -> bool:
	var movement: PlayerMovement = owner.get_meta(PlayerMovement.META_NAME, null)
	return movement != null and movement.is_running
