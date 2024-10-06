extends CharacterBody2D

@export var movement_speed: float = 100.0


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	if direction:
		velocity = direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
	move_and_slide()
