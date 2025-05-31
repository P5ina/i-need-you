extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var rotation_speed := 0.005
@export var min_rotation_angle := -60.0
@export var max_rotation_angle := 60.0

@export var movement_locked: bool
@export var view_locked: bool:
	set(value):
		view_locked = value
		if view_locked:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

@onready var head: Node3D = $Head


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if movement_locked:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and !view_locked:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()

	#if event.is_action_pressed("interact") and interactable_object != null:
		#interactable_object.interact(self)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion \
		and !view_locked:
		rotate_y(-event.relative.x * rotation_speed)
		head.rotation.x = clamp(
			head.rotation.x - event.relative.y * rotation_speed,
			deg_to_rad(min_rotation_angle),
			deg_to_rad(max_rotation_angle)
		)
