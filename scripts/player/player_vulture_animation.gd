class_name PlayerVultureAnimation
extends AnimatedSprite2D

enum AnimationDirection {
	UP,
	DOWN,
}

const META_NAME = &"PlayerVultureAnimation"


func _ready() -> void:
	owner.set_meta(META_NAME, self)


func play_step_animation(direction: AnimationDirection, is_right: bool) -> void:
	var leg: String = "r" if is_right else "l"
	var step_name: String = "up" if direction == AnimationDirection.UP else "down"
	var animation_name: String = "step_%s_%s" % [step_name, leg]
	play(animation_name)


func play_rotate_animation(direction: AnimationDirection) -> void:
	if direction == AnimationDirection.UP:
		play(&"idle_up")
	else:
		play(&"idle_down")
