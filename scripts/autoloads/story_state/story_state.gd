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
		return SaveManager.data.intro_played
	set(value):
		SaveManager.data.intro_played = value


func get_character_state(character_name: String) -> CharacterState:
	var char_data := SaveManager.get_character_data(character_name)
	return char_data.get("state", 0) as CharacterState


func set_character_state(character_name: String, state: CharacterState) -> void:
	SaveManager.set_character_data(character_name, "state", state as int)


func get_character_phase(character_name: String) -> String:
	var state := get_character_state(character_name)
	match state:
		CharacterState.NONE, CharacterState.BEGINING:
			return "BEGINNING"
		CharacterState.STORY, CharacterState.CONVINCE:
			return "CONVINCE"
		_:
			return "BEGINNING"


func save_state() -> void:
	SaveManager.save()


func load_state() -> void:
	if SaveManager.has_save():
		SaveManager.load_save()
