extends CanvasLayer

signal dialogue_manager_finished

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

const CHARACTER_PORTRAITS := {
	"vulture": preload("res://textures/characters/vulture/vulture_portraits.png"),
	"vulture_seller": preload("res://textures/characters/vulture/vulture_portraits.png"),
}

const EMOTION_FRAMES := {
	"neutral": 0,
	"vulnerable": 1,
	"retreating": 2,
	"defensive": 3,
	"hopeful": 4,
	"anxious": 5,
}

const PORTRAIT_FRAME_SIZE := 128

var is_typing := false
var full_text := ""
var story_ready := false

# DialogueManager
var dialogue_resource: DialogueResource
var dialogue_line: DialogueLine
var temporary_game_states: Array = []
var is_waiting_for_input := false

@onready var character_portrait: TextureRect = $CharacterPortrait
@onready var name_label: Label = $DialoguePanel/NameContainer/NameLabel
@onready var response_text: RichTextLabel = $DialoguePanel/TextContainer/ResponseText
@onready var next_indicator: Control = $DialoguePanel/TextContainer/NextIndicator
@onready var choices_container: VBoxContainer = $ChoicesContainer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("advance"):
		if not choices_container.visible:
			_handle_dialogue_manager_advance()
			get_viewport().set_input_as_handled()


func _handle_dialogue_manager_advance() -> void:
	if is_typing:
		_skip_typing()
	elif is_waiting_for_input and dialogue_line.responses.size() == 0:
		_next_dialogue_line(dialogue_line.next_id)


# ==================== DIALOGUE MANAGER ====================

func mark_story_ready() -> void:
	story_ready = true


func start_dialogue_manager(resource: DialogueResource, title: String = "", extra_game_states: Array = []) -> void:
	dialogue_resource = resource
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	story_ready = false
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
	_update_portrait_for_character(character)

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


# ==================== TYPING ====================

signal typing_finished


func _type_text(text: String) -> void:
	full_text = text
	is_typing = true
	next_indicator.visible = false
	response_text.text = ""
	response_text.visible_characters = 0
	response_text.text = text

	for i in range(text.length()):
		if not is_typing:
			break
		response_text.visible_characters = i + 1

		var ch := text[i]

		# Play sound every N characters (skip spaces and punctuation)
		if i % SOUND_INTERVAL == 0 and ch != " " and ch != "\n":
			_play_voice_sound()

		# Different delays for different characters
		var delay := CHAR_DELAY
		match ch:
			" ", "\n":
				delay = SPACE_DELAY
			",", ";", ":":
				delay = COMMA_DELAY
			".", "!", "?", "…":
				delay = PERIOD_DELAY

		await get_tree().create_timer(delay).timeout

	response_text.visible_characters = -1
	is_typing = false
	next_indicator.visible = true
	typing_finished.emit()


func _play_voice_sound() -> void:
	if voice_player.stream:
		voice_player.pitch_scale = randf_range(0.9, 1.1)
		voice_player.play()


func _skip_typing() -> void:
	is_typing = false
	response_text.visible_characters = -1


func _update_portrait_for_character(character: String) -> void:
	var emotion := "neutral"
	if dialogue_line and dialogue_line.get_tag_value("emotion"):
		emotion = dialogue_line.get_tag_value("emotion")
	_set_portrait(character, emotion)


func _set_portrait(character: String, emotion: String) -> void:
	if not CHARACTER_PORTRAITS.has(character):
		character_portrait.visible = false
		return

	character_portrait.visible = true
	var frame_index: int = EMOTION_FRAMES.get(emotion, 0)
	var source_texture: Texture2D = CHARACTER_PORTRAITS[character]

	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = Rect2(
		frame_index * PORTRAIT_FRAME_SIZE, 0,
		PORTRAIT_FRAME_SIZE, PORTRAIT_FRAME_SIZE
	)
	character_portrait.texture = atlas
