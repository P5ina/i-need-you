class_name CharacterInteractable
extends Interactable

@export_enum("vulture", "deer", "dog", "fish") var character_name: String
@export var facing_direction: PlayerAnimation.AnimationDirection
@export_file("*.tscn") var story_scene: String

@onready var character_camera_2d: PhantomCamera2D = $CharacterCamera2D
@onready var player_position: Node2D = $PlayerPosition


func _ready() -> void:
	super()
	if StoryState.get_character_state(character_name) == StoryState.CharacterState.BEGINING:
		interact(Gamemode.current_player)
	if StoryState.get_character_state(character_name) == StoryState.CharacterState.CONVINCE:
		after_story_dialogue()
	if StoryState.get_character_state(character_name) == StoryState.CharacterState.ENDING:
		queue_free()
	if StoryState.get_character_state(character_name) == StoryState.CharacterState.STORY:
		SceneLoader.transit_to_scene(story_scene)


func interact(player: CharacterBody2D) -> void:
	if StoryState.get_character_state(character_name) == StoryState.CharacterState.ENDING:
		return

	StoryState.set_character_state(character_name, StoryState.CharacterState.BEGINING)
	lock_player(player)
	Dialogic.start("vulture_begining")
	await Dialogic.timeline_ended

	if Dialogic.VAR.get(&"load_story"):
		Dialogic.VAR.set(&"load_story", false)
		StoryState.set_character_state(character_name, StoryState.CharacterState.STORY)
		SceneLoader.transit_to_scene(story_scene)
	else:
		StoryState.set_character_state(character_name, StoryState.CharacterState.NONE)
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
	Dialogic.start("vulture_convince")
	await Dialogic.timeline_ended

	StoryState.set_character_state(character_name, StoryState.CharacterState.ENDING)
	unlock_player(Gamemode.current_player)
	fade_out_character()


func fade_out_character() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(owner, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.tween_callback(owner.queue_free)
