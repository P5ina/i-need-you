extends Node

const SAVE_FILE = "user://story.save"

enum CharacterState {
	NONE,
	BEGINING,
	STORY,
	CONVINCE,
	ENDING,
}

var intro_played: bool:
	get:
		return _save_dictionary["intro_played"]
	set(value):
		_save_dictionary["intro_played"] = value

var _save_dictionary: Dictionary = {}

func _ready() -> void:
	load_state()

func get_character_state(character_name: String) -> CharacterState:
	return _save_dictionary[character_name + "_state"]


# TODO: Add save for dialogue lines to prevent abusing the save system
func save_state() -> void:
	Dialogic.Save.save("", false, Dialogic.Save.ThumbnailMode.NONE, _save_dictionary)


func load_state() -> void:
	_save_dictionary = Dialogic.Save.get_slot_info("")
