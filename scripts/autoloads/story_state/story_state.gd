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


func get_save_state() -> Dictionary:
	return {
		"intro_played": intro_played,
		"vulture_state": vulture_state,
	}

func set_save_state(state: Dictionary) -> void:
	intro_played = state["intro_played"]
	vulture_state = state["vulture_state"]


# TODO: Add save for dialogue lines to prevent abusing the save system
func save_state() -> void:
	var save_file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	var save: Dictionary = get_save_state()
	var json_string: String = JSON.stringify(save)
	save_file.store_line(json_string)


func load_state() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return

	var parser: JSON = JSON.new()

	var save_file: FileAccess = FileAccess.open("user://story.save", FileAccess.READ)
	var json_string: String = save_file.get_line()
	var parse_error: Error = parser.parse(json_string)
	if parse_error != OK:
		push_error("JSON Parse Error: ", parser.get_error_message(),
			" in ", json_string, " at line ", parser.get_error_line())

	var save: Dictionary = parser.data
	set_save_state(save)
