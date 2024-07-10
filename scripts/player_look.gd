extends Node3D

@export var sensitivity_y := 0.2
@export var sensitivity_x := 0.2
@export var max_angle := 80.
@export var min_angle := -80.

var camera_x := 0.


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			return

		var input_x: float = -event.relative.x * sensitivity_x
		owner.rotate_y(deg_to_rad(input_x))

		var input_y: float = -event.relative.y * sensitivity_y
		if camera_x + input_y < max_angle and camera_x + input_y > min_angle:
			camera_x += input_y
			self.rotate_x(deg_to_rad(input_y))
