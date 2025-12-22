extends Node2D

const AI_DIALOGUE_UI_SCENE := preload("res://scenes/ai_dialogue/ai_dialogue_ui.tscn")
const DIALOGUE_RESOURCE := preload("res://dialogues/dialogue_manager/vulture_story.dialogue")

@export var dialogue_start_position_y: float
@export var story_end_position_y: float

var dialogue_started: bool = false
var is_ended: bool = false
var dialogue_ui: CanvasLayer


func _process(_delta: float) -> void:
	if Gamemode.current_player.global_position.y <= dialogue_start_position_y and not dialogue_started:
		start_dialogue()
	elif Gamemode.current_player.global_position.y >= story_end_position_y and dialogue_started:
		story_ended()


func start_dialogue() -> void:
	var vertical_movement: VerticalMovement = Gamemode.current_player.get_meta(VerticalMovement.META_NAME)
	vertical_movement.movement_locked = true
	dialogue_started = true

	dialogue_ui = AI_DIALOGUE_UI_SCENE.instantiate()
	get_tree().root.add_child(dialogue_ui)
	dialogue_ui.start_dialogue_manager(DIALOGUE_RESOURCE, "start")
	await dialogue_ui.dialogue_manager_finished
	_cleanup_ui()

	vertical_movement.movement_locked = false
	vertical_movement.direction = Vector2.DOWN


func story_ended() -> void:
	if is_ended:
		return

	is_ended = true
	var vertical_movement: VerticalMovement = Gamemode.current_player.get_meta(VerticalMovement.META_NAME)
	vertical_movement.movement_locked = true
	StoryState.set_character_state("vulture", StoryState.CharacterState.CONVINCE)
	StoryLoader.load_back()


func _cleanup_ui() -> void:
	if dialogue_ui and is_instance_valid(dialogue_ui):
		dialogue_ui.queue_free()
		dialogue_ui = null
