extends Control

const INITIAL_SCENE = "res://scenes/her_side.tscn"

func _ready() -> void:
	StoryState.load_state()
	
	var last_scene: String = Dialogic.VAR.last_loaded_scene
	if last_scene == "":
		last_scene = INITIAL_SCENE
		Dialogic.VAR.last_loaded_scene = INITIAL_SCENE
	await SceneLoader.transition_finished
	SceneLoader.transit_to_scene(last_scene)
