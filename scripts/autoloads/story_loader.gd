extends Node

const her_side: String = "res://scenes/her_side.tscn"

const vulture_scene_path: String = "res://scenes/stories/vulture_story.tscn"
const deer_scene_path: String = "res://scenes/stories/vulture_story.tscn"

func load_vulture_story() -> void:
	StoryState.set_character_state("vulture", StoryState.CharacterState.STORY)
	SceneLoader.transit_to_scene(vulture_scene_path)


func load_deer_story() -> void:
	StoryState.set_character_state("deer", StoryState.CharacterState.STORY)
	SceneLoader.transit_to_scene(deer_scene_path)


func load_back() -> void:
	var selected_scene: String = her_side
	if Dialogic.VAR.player_side == 0:
		selected_scene = her_side

	SceneLoader.transit_to_scene(selected_scene)
