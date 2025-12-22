extends Node

signal dialogue_received(response: Dictionary)
signal opening_received(opening: String)
signal story_received(lines: Array)
signal error_occurred(message: String)

@export var server_url: String = "http://localhost:8000"

var http_request: HTTPRequest
var opening_request: HTTPRequest
var current_character: String = ""
var dialogue_history: Array = []
var total_points: float = 0.0


func get_current_phase() -> String:
	return StoryState.get_character_phase(current_character)


func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	opening_request = HTTPRequest.new()
	add_child(opening_request)
	opening_request.request_completed.connect(_on_opening_completed)


func start_dialogue(character: String) -> void:
	current_character = character
	dialogue_history = []
	total_points = 0.0


func get_opening_line() -> void:
	var url: String = server_url + "/opening/" + current_character + "/" + get_current_phase()

	var error: Error = opening_request.request(url)
	if error != OK:
		error_occurred.emit("Failed to get opening: " + str(error))


func send_message(player_input: String) -> void:
	var url: String = server_url + "/dialogue"

	var body: Dictionary = {
		"character": current_character,
		"phase": get_current_phase(),
		"player_input": player_input,
		"history": dialogue_history,
		"total_points": total_points
	}

	var json_body: String = JSON.stringify(body)
	var headers: PackedStringArray = ["Content-Type: application/json"]

	var error: Error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		error_occurred.emit("Failed to send request: " + str(error))


func get_story(character: String) -> void:
	var url: String = server_url + "/story/" + character

	var error: Error = http_request.request(url)
	if error != OK:
		error_occurred.emit("Failed to get story: " + str(error))


func reset() -> void:
	dialogue_history = []
	total_points = 0.0


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		error_occurred.emit("Request failed with result: " + str(result))
		return

	if response_code != 200:
		error_occurred.emit("Server error: " + str(response_code))
		return

	var json_string: String = body.get_string_from_utf8()
	var json: Variant = JSON.parse_string(json_string)

	if json == null:
		error_occurred.emit("Failed to parse JSON response")
		return

	if json is not Dictionary:
		error_occurred.emit("Invalid response format")
		return

	var response: Dictionary = json as Dictionary

	if response.has("lines"):
		story_received.emit(response.lines)
		return

	if response.has("dialogue"):
		total_points = response.get("total_points", total_points)

		dialogue_history.append({
			"role": "assistant",
			"content": response.dialogue
		})

		dialogue_received.emit(response)


func _on_opening_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		error_occurred.emit("Opening request failed: " + str(result))
		return

	if response_code != 200:
		error_occurred.emit("Opening server error: " + str(response_code))
		return

	var json_string: String = body.get_string_from_utf8()
	var json: Variant = JSON.parse_string(json_string)

	if json == null or json is not Dictionary:
		error_occurred.emit("Failed to parse opening response")
		return

	var response: Dictionary = json as Dictionary
	var opening: String = response.get("opening", "...")
	opening_received.emit(opening)
