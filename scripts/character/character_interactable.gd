class_name CharacterInteractable
extends Interactable

@export var facing_direction: PlayerAnimation.AnimationDirection
@export_file("*.tscn") var story_scene: String

@onready var character_camera_2d: PhantomCamera2D = $CharacterCamera2D
@onready var player_position: Node2D = $PlayerPosition

func _ready() -> void:
	super()
	if StoryState.vulture_state == StoryState.CharacterState.CONVINCE:
		after_story_dialogue()


func interact(player: CharacterBody2D) -> void:
	StoryState.vulture_state = StoryState.CharacterState.BEGINING
	character_camera_2d.priority = 50
	snap_player(player)
	Dialogic.start("vulture_begining")
	await Dialogic.timeline_ended

	if Dialogic.VAR.get(&"load_story"):
		Dialogic.VAR.set(&"load_story", false)
		StoryState.vulture_state = StoryState.CharacterState.STORY
		SceneLoader.transit_to_scene(story_scene)
	else:
		StoryState.vulture_state = StoryState.CharacterState.NONE
		character_camera_2d.priority = 0
		interaction_ended.emit()


func snap_player(player: Node2D) -> void:
	player.get_meta(PlayerAnimation.META_NAME).update_animation(facing_direction, false)
	player.global_position = player_position.global_position


func after_story_dialogue() -> void:
	snap_player(Gamemode.current_player)
