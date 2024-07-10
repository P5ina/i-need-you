class_name Player
extends CharacterBody3D

@export var speed := 3.0
@export var stop_duration := 1.0

var direction: Vector3

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
		var new_horizontal_velocity := horizontal_velocity.move_toward(Vector3.ZERO, (speed / stop_duration) * delta)
		velocity.x = new_horizontal_velocity.x
		velocity.z =new_horizontal_velocity.z

	move_and_slide()


func is_moving() -> bool:
	return direction.length_squared() > 0 
