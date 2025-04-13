class_name CharacterInteractable
extends Interactable

@export_enum("vulture", "deer", "dog", "fish") var character_name: String
@export var facing_direction: PlayerAnimation.AnimationDirection
@export_file("*.tscn") var story_scene: String
@export var begin_dialogue: String
@export var convince_dialogue: String

@onready var character_camera_2d: PhantomCamera2D = $CharacterCamera2D
@onready var player_position: Node2D = $PlayerPosition


func _ready() -> void:
	super()
	var state := StoryState.get_character_state(character_name)
	if state == StoryState.CharacterState.BEGINING:
		interact(Gamemode.current_player)
	elif state == StoryState.CharacterState.CONVINCE:
		after_story_dialogue()
	elif state == StoryState.CharacterState.ENDING:
		queue_free()
	elif state == StoryState.CharacterState.STORY:
		SceneLoader.transit_to_scene(story_scene)


func interact(player: CharacterBody2D) -> void:
	if StoryState.get_character_state(character_name) == StoryState.CharacterState.ENDING:
		return

	lock_player(player)
	Dialogic.start(begin_dialogue)
	await Dialogic.timeline_ended

	var state := StoryState.get_character_state(character_name)
	print("Character end state: ", state)
	print("Character raw state: ", StoryState.CharacterState.NONE)
	if state == StoryState.CharacterState.NONE:
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
	Dialogic.start(convince_dialogue)
	await Dialogic.timeline_ended

	StoryState.set_character_state(character_name, StoryState.CharacterState.ENDING)
	unlock_player(Gamemode.current_player)
	fade_out_character()


func fade_out_character() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(owner, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.tween_callback(owner.queue_free)
