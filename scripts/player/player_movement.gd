extends Node

const META_NAME = &"MovementComponent"

@export var movement_speed: float = 50.0

var interaction_area: InteractionArea
var movement_locked: bool


func _ready() -> void:
	owner.set_meta(META_NAME, self)
	interaction_area = owner.get_meta(InteractionArea.META_NAME)
	interaction_area.interaction_started.connect(_on_interaction_started)
	interaction_area.interaction_ended.connect(_on_interaction_ended)


func _on_interaction_started() -> void:
	movement_locked = true


func _on_interaction_ended() -> void:
	movement_locked = false


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	if direction and not movement_locked:
		owner.velocity = direction * movement_speed
	else:
		owner.velocity = owner.velocity.move_toward(Vector2.ZERO, movement_speed)
	owner.move_and_slide()
