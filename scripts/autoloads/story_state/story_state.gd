extends Node

const SAVE_FILE = "user://story.save"

var intro_played: bool = false

func _ready() -> void:
	load_state()


func get_save_state() -> Dictionary:
	return {
		"intro_played": intro_played
	}


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
	intro_played = save["intro_played"]
