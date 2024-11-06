extends Node2D

@export var dialogue_start_position_y: float
@export var story_end_position_y: float

var dialogue_started: bool = false


func _process(_delta: float) -> void:
	if Gamemode.current_player.global_position.y <= dialogue_start_position_y and not dialogue_started:
		start_dialogue()
	elif Gamemode.current_player.global_position.y >= story_end_position_y and dialogue_started:
		story_ended()


func start_dialogue() -> void:
	var vertical_movement: VerticalMovement = Gamemode.current_player.get_meta(VerticalMovement.META_NAME)
	vertical_movement.movement_locked = true
	dialogue_started = true
	Dialogic.start("vulture_story")
	await Dialogic.timeline_ended

	vertical_movement.movement_locked = false
	vertical_movement.direction = Vector2.DOWN


func story_ended() -> void:
	var vertical_movement: VerticalMovement = Gamemode.current_player.get_meta(VerticalMovement.META_NAME)
	vertical_movement.movement_locked = true
	StoryState.vulture_state = StoryState.CharacterState.CONVINCE
	SceneLoader.transit_to_scene("res://scenes/her_side.tscn")
