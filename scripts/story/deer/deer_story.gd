extends Node2D

const BURNING_FOREST_SCENE := "res://scenes/stories/deer/deer_burning_forest.tscn"

@export var female_deer: Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var deer_player: CharacterBody2D = $DeerPlayer


func _ready() -> void:
	var movement: PlayerMovement = deer_player.get_meta(PlayerMovement.META_NAME)
	movement.movement_locked = true

	var interactable: FemaleDeerInteractable = female_deer.get_node("Interactable")
	interactable.dialogue_finished.connect(_on_dialogue_finished)

	await animation_player.animation_finished
	movement.movement_locked = false


func _on_dialogue_finished() -> void:
	SceneLoader.transit_to_scene(BURNING_FOREST_SCENE)
