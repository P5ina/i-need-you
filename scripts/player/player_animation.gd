class_name PlayerAnimation
extends AnimatedSprite2D

const META_NAME = &"AnimationComponent"

enum AnimationDirection {
	UP,
	RIGHT,
	DOWN,
	LEFT,
}

var last_direction: AnimationDirection = AnimationDirection.DOWN
var last_is_moving: bool = false


func _ready() -> void:
	owner.set_meta(META_NAME, self)


func _process(_delta: float) -> void:
	var normalized_velocity: Vector2 = (owner as CharacterBody2D).velocity.normalized()
	var direction: AnimationDirection = get_direction(normalized_velocity)
	var is_moving: bool = normalized_velocity.length() > 0.1

	update_animation(direction, is_moving)


func get_direction(normalized_velocity: Vector2) -> AnimationDirection:
	if normalized_velocity.y < 0:
		return AnimationDirection.UP
	elif normalized_velocity.y > 0:
		return AnimationDirection.DOWN
	elif normalized_velocity.x > 0:
		return AnimationDirection.RIGHT
	elif normalized_velocity.x < 0:
		return AnimationDirection.LEFT

	return last_direction if last_direction != null else AnimationDirection.DOWN


func update_animation(direction: AnimationDirection, is_moving: bool) -> void:
	if direction == last_direction and is_moving == last_is_moving:
		return

	last_direction = direction
	last_is_moving = is_moving
	play(direction_to_animation_name(direction, is_moving))


func direction_to_animation_name(direction: AnimationDirection, is_moving: bool) -> String:
	var direction_name: String = ["up", "right", "down", "left"][direction]
	var state: String = "walk" if is_moving else "idle"
	return state + "_" + direction_name
