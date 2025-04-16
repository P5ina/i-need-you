extends Node

const her_side: String = "res://scenes/her_side.tscn"

#const vulture_scene_path: String = "res://scenes/stories/vulture/vulture_story.tscn"
#const deer_scene_path: String = "res://scenes/stories/deer/deer_story.tscn"
#
#func load_vulture_story() -> void:
	#StoryState.set_character_state("vulture", StoryState.CharacterState.STORY)
	#StoryState.save_state()
	#SceneLoader.transit_to_scene(vulture_scene_path)
#
#
#func load_deer_story() -> void:
	#StoryState.set_character_state("deer", StoryState.CharacterState.STORY)
	#StoryState.save_state()
	#SceneLoader.transit_to_scene(deer_scene_path)


func load_scene_and_save(scene_path: String) -> void:
	SceneLoader.transit_to_scene(scene_path)
	Dialogic.VAR.last_loaded_scene = scene_path
	StoryState.save_state()


func load_back() -> void:
	var selected_scene: String = her_side
	if Dialogic.VAR.player_side == 0:
		selected_scene = her_side

	load_scene_and_save(selected_scene)
