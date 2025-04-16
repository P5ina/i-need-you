extends Button

const LOADING_SCENE = "res://scenes/loading.tscn"

func _on_pressed() -> void:
	SceneLoader.transit_to_scene(LOADING_SCENE)
