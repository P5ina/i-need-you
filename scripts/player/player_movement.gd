class_name PlayerMovement
extends Node

const META_NAME = &"PlayerMovement"

@export var movement_speed: float = 50.0
@export var movement_locked: bool

var interaction_area: InteractionArea


func _ready() -> void:
	owner.set_meta(META_NAME, self)
	interaction_area = owner.get_meta(InteractionArea.META_NAME)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	if direction and not movement_locked:
		owner.velocity = direction * movement_speed
	else:
		owner.velocity = Vector2.ZERO
	owner.move_and_slide()
