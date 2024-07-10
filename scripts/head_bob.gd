extends Node

@export var frequency: float
@export var amplitude_x: float
@export var amplitude_y: float
@export var smooth_speed := 1.

@export var camera_look_node: Node3D
@export var player_movement: Player

var start_position: Vector3
var camera_node: Node3D
var target_position: Vector3

func _ready() -> void:
	camera_node = get_parent()
	assert(camera_node is Node3D)
	start_position = camera_node.position
	target_position = start_position

func _process(delta: float) -> void:
	target_position = get_target_position()
	apply_smoothed_position(target_position, delta)
	
	camera_node.look_at(get_focus_position())


func get_target_position() -> Vector3:
	if player_movement.is_moving() and player_movement.is_on_floor():
		return get_footstep_motion_position()
	return start_position


func get_footstep_motion_position() -> Vector3:
	var time: float = Time.get_ticks_msec() / 1000.0
	var x: float = cos(time * frequency / 2) * amplitude_x
	var y: float = sin(time * frequency) * amplitude_y
	return Vector3(x, y, 0)


func apply_smoothed_position(pos: Vector3, delta: float) -> void:
	if (camera_node.position == pos):
		return
	camera_node.position = camera_node.position.lerp(pos, smooth_speed * delta)


func get_focus_position() -> Vector3:
	var pos := camera_look_node.global_position
	pos += -camera_look_node.global_basis.z * 15.0
	return pos
