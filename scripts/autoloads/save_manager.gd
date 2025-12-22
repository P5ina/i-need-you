extends Node

signal saved
signal loaded

const SAVE_DIR := "user://saves/"
const SAVE_FILE := "save.json"

var data: Dictionary = {
	"intro_played": false,
	"last_loaded_scene": "",
	"player_side": 0,
	"characters": {
		"vulture": {"state": 0, "dialogue_history": [], "total_points": 0.0},
		"deer": {"state": 0, "dialogue_history": [], "total_points": 0.0},
		"dog": {"state": 0, "dialogue_history": [], "total_points": 0.0},
		"fish": {"state": 0, "dialogue_history": [], "total_points": 0.0},
	}
}


func _ready() -> void:
	_ensure_save_dir()


func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)


func save() -> void:
	_ensure_save_dir()
	var file := FileAccess.open(SAVE_DIR + SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		saved.emit()


func load_save() -> void:
	if not has_save():
		return

	var file := FileAccess.open(SAVE_DIR + SAVE_FILE, FileAccess.READ)
	if file:
		var json_string := file.get_as_text()
		file.close()
		var parsed: Variant = JSON.parse_string(json_string)
		if parsed is Dictionary:
			_merge_data(parsed as Dictionary)
			loaded.emit()


func _merge_data(loaded_data: Dictionary) -> void:
	for key: String in data.keys():
		if loaded_data.has(key):
			if data[key] is Dictionary and loaded_data[key] is Dictionary:
				for sub_key: String in data[key].keys():
					if loaded_data[key].has(sub_key):
						data[key][sub_key] = loaded_data[key][sub_key]
			else:
				data[key] = loaded_data[key]


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_DIR + SAVE_FILE)


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_DIR + SAVE_FILE)


func reset() -> void:
	data = {
		"intro_played": false,
		"last_loaded_scene": "",
		"player_side": 0,
		"characters": {
			"vulture": {"state": 0, "dialogue_history": [], "total_points": 0.0},
			"deer": {"state": 0, "dialogue_history": [], "total_points": 0.0},
			"dog": {"state": 0, "dialogue_history": [], "total_points": 0.0},
			"fish": {"state": 0, "dialogue_history": [], "total_points": 0.0},
		}
	}


func get_character_data(character_name: String) -> Dictionary:
	if data.characters.has(character_name):
		return data.characters[character_name]
	return {}


func set_character_data(character_name: String, key: String, value: Variant) -> void:
	if data.characters.has(character_name):
		data.characters[character_name][key] = value
