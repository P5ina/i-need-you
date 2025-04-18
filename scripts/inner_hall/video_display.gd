extends MeshInstance3D

@onready var sub_viewport: SubViewport = $SubViewport

var _mat: StandardMaterial3D

func _ready() -> void:
	_mat = get_surface_override_material(0)

func _process(_delta: float) -> void:
	_mat.albedo_texture = sub_viewport.get_texture()
