class_name CharacterInteractable
extends Interactable

const AI_DIALOGUE_UI_SCENE := preload("res://scenes/ai_dialogue/ai_dialogue_ui.tscn")

@export_enum("vulture", "deer", "dog", "fish") var character_name: String
@export var facing_direction: PlayerAnimation.AnimationDirection
@export_file("*.tscn") var story_scene: String
@export var beginning_dialogue: DialogueResource
@export var convince_dialogue: DialogueResource

@onready var character_camera_2d: PhantomCamera2D = $CharacterCamera2D
@onready var player_position: Node2D = $PlayerPosition

var dialogue_ui: CanvasLayer


func _ready() -> void:
	super()
	var state := StoryState.get_character_state(character_name)
	if state == StoryState.CharacterState.BEGINING:
		interact(Gamemode.current_player)
	elif state == StoryState.CharacterState.CONVINCE:
		after_story_dialogue()
	elif state == StoryState.CharacterState.ENDING:
		owner.queue_free()
	elif state == StoryState.CharacterState.STORY:
		SceneLoader.transit_to_scene(story_scene)


func interact(player: CharacterBody2D) -> void:
	if StoryState.get_character_state(character_name) == StoryState.CharacterState.ENDING:
		return

	lock_player(player)

	dialogue_ui = AI_DIALOGUE_UI_SCENE.instantiate()
	get_tree().root.add_child(dialogue_ui)

	dialogue_ui.start_dialogue_manager(beginning_dialogue, "start")
	await dialogue_ui.dialogue_manager_finished
	var should_load_story: bool = dialogue_ui.story_ready
	_cleanup_ui()

	if should_load_story:
		StoryState.set_character_state(character_name, StoryState.CharacterState.STORY)
		StoryLoader.load_scene_and_save(story_scene)
	else:
		unlock_player(player)


func lock_player(player: Node2D) -> void:
	character_camera_2d.priority = 50
	player.get_meta(InteractionArea.META_NAME).current_interaction = self
	player.get_meta(PlayerAnimation.META_NAME).update_animation(facing_direction, false)
	player.get_meta(PlayerMovement.META_NAME).movement_locked = true
	player.global_position = player_position.global_position


func unlock_player(player: Node2D) -> void:
	character_camera_2d.priority = 0
	player.get_meta(InteractionArea.META_NAME).current_interaction = null
	player.get_meta(PlayerMovement.META_NAME).movement_locked = false
	interaction_ended.emit()


func after_story_dialogue() -> void:
	await get_tree().process_frame
	lock_player(Gamemode.current_player)

	dialogue_ui = AI_DIALOGUE_UI_SCENE.instantiate()
	get_tree().root.add_child(dialogue_ui)

	dialogue_ui.start_dialogue_manager(convince_dialogue, "start")
	await dialogue_ui.dialogue_manager_finished
	_cleanup_ui()

	StoryState.set_character_state(character_name, StoryState.CharacterState.ENDING)
	StoryState.save_state()
	unlock_player(Gamemode.current_player)
	fade_out_character()


func _cleanup_ui() -> void:
	if dialogue_ui and is_instance_valid(dialogue_ui):
		dialogue_ui.queue_free()
		dialogue_ui = null


func fade_out_character() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(owner, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.tween_callback(owner.queue_free)
