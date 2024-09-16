extends Button

@export_file("*.tscn") var her_side_scene: String


func _on_pressed() -> void:
	SceneLoader.transit_to_scene(her_side_scene)
