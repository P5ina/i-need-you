extends CanvasLayer

signal dialogue_finished(ending: String)
signal cutscene_finished
signal dialogue_manager_finished

enum Mode { AI_DIALOGUE, CUTSCENE, DIALOGUE_MANAGER }

const CHAR_DELAY := 0.025
const SPACE_DELAY := 0.04
const COMMA_DELAY := 0.15
const PERIOD_DELAY := 0.25
const SOUND_INTERVAL := 3  # Play sound every N characters

const CHARACTER_SOUNDS := {
	"Стервятник": preload("res://sounds/characters/vulture/vulture_talking.mp3"),
	"Олень": preload("res://sounds/characters/deer/deer_talking.wav"),
	"Пёс": preload("res://sounds/characters/dog/dog_talking_a.wav"),
	"Рыба": preload("res://sounds/characters/character_talking.wav"),
	"Торговец": preload("res://sounds/characters/vulture_seller/seller_talking_1.mp3"),
	"vulture": preload("res://sounds/characters/vulture/vulture_talking.mp3"),
	"deer": preload("res://sounds/characters/deer/deer_talking.wav"),
	"dog": preload("res://sounds/characters/dog/dog_talking_a.wav"),
	"fish": preload("res://sounds/characters/character_talking.wav"),
	"vulture_seller": preload("res://sounds/characters/vulture_seller/seller_talking_1.mp3"),
	"he": preload("res://sounds/characters/character_talking.wav"),
	"she": preload("res://sounds/characters/character_talking.wav"),
}

const CHARACTER_DISPLAY_NAMES := {
	"vulture": "Стервятник",
	"deer": "Олень",
	"dog": "Пёс",
	"fish": "Рыба",
	"vulture_seller": "Торговец",
	"he": "Он",
	"she": "Она",
}

var current_mode: Mode = Mode.AI_DIALOGUE
var is_typing := false
var full_text := ""
var cutscene_lines: Array[String] = []
var cutscene_index := 0

# DialogueManager
var dialogue_resource: DialogueResource
var dialogue_line: DialogueLine
var temporary_game_states: Array = []
var is_waiting_for_input := false

@onready var character_portrait: TextureRect = $CharacterPortrait
@onready var name_label: Label = $DialoguePanel/NameContainer/NameLabel
@onready var response_text: RichTextLabel = $DialoguePanel/TextContainer/ResponseText
@onready var next_indicator: Control = $DialoguePanel/TextContainer/NextIndicator
@onready var input_container: HBoxContainer = $DialoguePanel/InputContainer
@onready var player_input: LineEdit = $DialoguePanel/InputContainer/PlayerInput
@onready var send_button: Button = $DialoguePanel/InputContainer/SendButton
@onready var choices_container: VBoxContainer = $ChoicesContainer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer


func _ready() -> void:
	visible = false
	send_button.pressed.connect(_on_send_pressed)
	player_input.text_submitted.connect(_on_text_submitted)
	AIDialogueClient.dialogue_received.connect(_on_dialogue_received)
	AIDialogueClient.opening_received.connect(_on_opening_received)
	AIDialogueClient.error_occurred.connect(_on_error)


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("advance"):
		match current_mode:
			Mode.AI_DIALOGUE:
				if next_indicator.visible:
					advance_pressed.emit()
					get_viewport().set_input_as_handled()
			Mode.CUTSCENE:
				_handle_cutscene_advance()
				get_viewport().set_input_as_handled()
			Mode.DIALOGUE_MANAGER:
				if not choices_container.visible:
					_handle_dialogue_manager_advance()
					get_viewport().set_input_as_handled()


func _handle_cutscene_advance() -> void:
	if is_typing:
		_skip_typing()
	else:
		_next_cutscene_line()


func _handle_dialogue_manager_advance() -> void:
	if is_typing:
		_skip_typing()
	elif is_waiting_for_input and dialogue_line.responses.size() == 0:
		_next_dialogue_line(dialogue_line.next_id)


# ==================== AI DIALOGUE ====================

func start_ai_dialogue(character_name: String, display_name: String) -> void:
	current_mode = Mode.AI_DIALOGUE
	_setup_mode()
	name_label.text = display_name
	response_text.text = "..."
	player_input.text = ""
	player_input.editable = false

	# Load saved data for this character
	var char_data := SaveManager.get_character_data(character_name)
	AIDialogueClient.start_dialogue(character_name)
	AIDialogueClient.total_points = char_data.get("total_points", 0.0)
	AIDialogueClient.dialogue_history = char_data.get("dialogue_history", [])

	AIDialogueClient.get_opening_line()
	visible = true


func _on_send_pressed() -> void:
	_send_message()


func _on_text_submitted(_text: String) -> void:
	_send_message()


func _send_message() -> void:
	var text := player_input.text.strip_edges()
	if text.is_empty():
		return

	player_input.editable = false
	response_text.text = "..."

	AIDialogueClient.dialogue_history.append({
		"role": "user",
		"content": text
	})
	AIDialogueClient.send_message(text)
	player_input.text = ""


func _on_dialogue_received(response: Dictionary) -> void:
	var dialogue_text: String = response.get("dialogue", "")
	var emotion: String = response.get("emotion", "neutral")
	var should_end: bool = response.get("should_end", false)
	var ending: String = response.get("ending", "none")
	var ready_for_story: bool = response.get("ready_for_story", false)

	_update_emotion(emotion)
	_type_text(dialogue_text)
	await typing_finished

	if should_end or ready_for_story:
		input_container.visible = false
		next_indicator.visible = true
		await _wait_for_advance()
		var final_ending := "story" if ready_for_story else ending
		_end_dialogue(final_ending)
	else:
		player_input.editable = true
		player_input.grab_focus()


func _end_dialogue(ending: String) -> void:
	# Save points and history to SaveManager
	var character := AIDialogueClient.current_character
	SaveManager.set_character_data(character, "total_points", AIDialogueClient.total_points)
	SaveManager.set_character_data(character, "dialogue_history", AIDialogueClient.dialogue_history)
	SaveManager.save()

	visible = false
	dialogue_finished.emit(ending)


func _on_error(message: String) -> void:
	response_text.text = "[color=red]Error: " + message + "[/color]"
	player_input.editable = true


func _on_opening_received(opening: String) -> void:
	_type_text(opening)
	await typing_finished
	player_input.editable = true
	player_input.grab_focus()


# ==================== CUTSCENE ====================

func start_cutscene(display_name: String, lines: Array[String]) -> void:
	current_mode = Mode.CUTSCENE
	_setup_mode()
	name_label.text = display_name
	cutscene_lines = lines
	cutscene_index = 0
	visible = true
	_show_cutscene_line()


func _show_cutscene_line() -> void:
	if cutscene_index >= cutscene_lines.size():
		_end_cutscene()
		return

	var line := cutscene_lines[cutscene_index]
	_type_text(line)


func _next_cutscene_line() -> void:
	cutscene_index += 1
	_show_cutscene_line()


func _end_cutscene() -> void:
	visible = false
	cutscene_finished.emit()


# ==================== DIALOGUE MANAGER ====================

func start_dialogue_manager(resource: DialogueResource, title: String = "", extra_game_states: Array = []) -> void:
	current_mode = Mode.DIALOGUE_MANAGER
	_setup_mode()
	dialogue_resource = resource
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	visible = true

	dialogue_line = await dialogue_resource.get_next_dialogue_line(title, temporary_game_states)
	_apply_dialogue_line()


func _apply_dialogue_line() -> void:
	if dialogue_line == null:
		_end_dialogue_manager()
		return

	next_indicator.visible = false
	is_waiting_for_input = false

	var character := dialogue_line.character
	name_label.visible = not character.is_empty()
	name_label.text = CHARACTER_DISPLAY_NAMES.get(character, character)

	_update_voice_sound_for_character(character)

	_clear_responses()
	choices_container.visible = false

	if not dialogue_line.text.is_empty():
		_type_text(dialogue_line.text)
		await typing_finished

	if dialogue_line.responses.size() > 0:
		_show_responses()
	else:
		is_waiting_for_input = true
		next_indicator.visible = true


func _next_dialogue_line(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)
	_apply_dialogue_line()


func _show_responses() -> void:
	_clear_responses()
	choices_container.visible = true
	next_indicator.visible = false

	for response: DialogueResponse in dialogue_line.responses:
		var button := Button.new()
		button.text = response.text
		button.theme = preload("res://dialogues/style/yni_ui_theme.tres")
		button.pressed.connect(_on_response_selected.bind(response))
		choices_container.add_child(button)

	await get_tree().process_frame
	if choices_container.get_child_count() > 0:
		choices_container.get_child(0).grab_focus()


func _on_response_selected(response: DialogueResponse) -> void:
	_clear_responses()
	choices_container.visible = false
	_next_dialogue_line(response.next_id)


func _clear_responses() -> void:
	for child in choices_container.get_children():
		child.queue_free()


func _update_voice_sound_for_character(character: String) -> void:
	if CHARACTER_SOUNDS.has(character):
		voice_player.stream = CHARACTER_SOUNDS[character]
	else:
		voice_player.stream = null


func _end_dialogue_manager() -> void:
	visible = false
	dialogue_manager_finished.emit()


# ==================== COMMON ====================

func _setup_mode() -> void:
	choices_container.visible = false
	_clear_responses()

	match current_mode:
		Mode.AI_DIALOGUE:
			input_container.visible = true
			next_indicator.visible = false
		Mode.CUTSCENE:
			input_container.visible = false
			next_indicator.visible = true
		Mode.DIALOGUE_MANAGER:
			input_container.visible = false
			next_indicator.visible = true


signal typing_finished


func _type_text(text: String) -> void:
	full_text = text
	is_typing = true
	next_indicator.visible = false
	response_text.text = ""
	response_text.visible_characters = 0
	response_text.text = text

	_update_voice_sound()

	for i in range(text.length()):
		if not is_typing:
			break
		response_text.visible_characters = i + 1

		var char := text[i]

		# Play sound every N characters (skip spaces and punctuation)
		if i % SOUND_INTERVAL == 0 and char != " " and char != "\n":
			_play_voice_sound()

		# Different delays for different characters
		var delay := CHAR_DELAY
		match char:
			" ", "\n":
				delay = SPACE_DELAY
			",", ";", ":":
				delay = COMMA_DELAY
			".", "!", "?", "…":
				delay = PERIOD_DELAY

		await get_tree().create_timer(delay).timeout

	response_text.visible_characters = -1
	is_typing = false

	# Show next indicator for cutscene/scripted modes
	if current_mode != Mode.AI_DIALOGUE:
		next_indicator.visible = true

	typing_finished.emit()


func _update_voice_sound() -> void:
	var speaker := name_label.text
	if CHARACTER_SOUNDS.has(speaker):
		voice_player.stream = CHARACTER_SOUNDS[speaker]
	else:
		voice_player.stream = null


func _play_voice_sound() -> void:
	if voice_player.stream:
		voice_player.pitch_scale = randf_range(0.9, 1.1)
		voice_player.play()


func _skip_typing() -> void:
	is_typing = false
	response_text.visible_characters = -1


signal advance_pressed


func _wait_for_advance() -> void:
	await advance_pressed


func _update_emotion(emotion: String) -> void:
	# TODO: Update character portrait based on emotion
	pass
