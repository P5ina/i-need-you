extends Node

@export var frequency: float
@export var amplitude: float
@export var smooth_speed := 1.

@export var player_movement: Player

var start_position: Vector3
var target_node: Node3D
var target_position: Vector3

func _ready() -> void:
	target_node = get_parent()
	assert(target_node is Node3D)
	start_position = target_node.position
	target_position = start_position

func _process(delta: float) -> void:
	target_position = get_target_position()
	
	apply_smoothed_position(target_position, delta)


func get_target_position() -> Vector3:
	if player_movement.is_moving() and player_movement.is_on_floor():
		return get_footstep_motion_position()
	return start_position


func get_footstep_motion_position() -> Vector3:
	var time: float = Time.get_ticks_msec() / 1000.0
	var x: float = cos(time * frequency / 2) * amplitude * 2
	var y: float = sin(time * frequency) * amplitude
	return Vector3(x, y, 0)


func apply_smoothed_position(pos: Vector3, delta: float) -> void:
	if (target_node.position == pos):
		return
	target_node.position = target_node.position.lerp(pos, smooth_speed * delta)
