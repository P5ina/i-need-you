class_name FemaleDeerInteractable
extends Interactable

const AI_DIALOGUE_UI_SCENE := preload("res://scenes/ai_dialogue/ai_dialogue_ui.tscn")

signal dialogue_finished

@export var dialogue_resource: DialogueResource
@export var facing_direction: PlayerAnimation.AnimationDirection

@onready var character_camera_2d: PhantomCamera2D = $CharacterCamera2D
@onready var player_position: Node2D = $PlayerPosition

var _dialogue_ui: CanvasLayer
var _triggered: bool = false


func interact(player: CharacterBody2D) -> void:
	if _triggered:
		return
	_triggered = true

	_lock_player(player)

	_dialogue_ui = AI_DIALOGUE_UI_SCENE.instantiate()
	get_tree().root.add_child(_dialogue_ui)
	_dialogue_ui.start_dialogue_manager(dialogue_resource, "start")
	await _dialogue_ui.dialogue_manager_finished
	_cleanup_ui()

	dialogue_finished.emit()


func _lock_player(player: CharacterBody2D) -> void:
	var interaction_area: InteractionArea = player.get_meta(InteractionArea.META_NAME)
	var animation: PlayerAnimation = player.get_meta(PlayerAnimation.META_NAME)
	var movement: PlayerMovement = player.get_meta(PlayerMovement.META_NAME)
	character_camera_2d.priority = 50
	interaction_area.current_interaction = self
	animation.update_animation(facing_direction, false)
	movement.movement_locked = true
	player.global_position = player_position.global_position


func _cleanup_ui() -> void:
	if _dialogue_ui and is_instance_valid(_dialogue_ui):
		_dialogue_ui.queue_free()
		_dialogue_ui = null
