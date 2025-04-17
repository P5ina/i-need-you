extends Node

enum CharacterState {
	NONE = 0,
	BEGINING = 1,
	STORY = 2,
	CONVINCE = 3,
	ENDING = 4,
}

var intro_played: bool:
	get:
		return Dialogic.VAR.intro_played
	set(value):
		Dialogic.VAR.intro_played = value


func get_character_state(character_name: String) -> CharacterState:
	return Dialogic.VAR.get(character_name).get("state") as CharacterState


func set_character_state(character_name: String, state: CharacterState) -> void:
	Dialogic.VAR.get(character_name).set("state", state as int)


func save_state() -> void:
	Dialogic.Save.save()


func load_state() -> void:
	if Dialogic.Save.has_slot(""):
		Dialogic.Save.load()
