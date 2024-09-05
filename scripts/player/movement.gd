extends Node

@export var movement_speed: float = 100.0

var character_body: CharacterBody2D
var direction: Vector2

func _ready() -> void:
	assert(owner is CharacterBody2D)
	character_body = owner

func _input(event: InputEvent) -> void:
	direction = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	).normalized()


func _physics_process(_delta: float) -> void:
	character_body.velocity = direction * movement_speed
	character_body.move_and_slide()
