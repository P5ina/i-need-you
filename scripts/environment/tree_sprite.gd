extends MeshInstance2D


func _ready() -> void:
	material = material.duplicate()
	_update_world_pos()


func _update_world_pos() -> void:
	material.set_shader_parameter("world_position", global_position)
	material.set_shader_parameter("time_offset", randf() * 10.0)
