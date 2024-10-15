class_name CharacterInteractable
extends Interactable

@onready var character_camera_2d: PhantomCamera2D = $CharacterCamera2D
@onready var player_position: Node2D = $PlayerPosition


func interact(_player: CharacterBody2D) -> void:
	character_camera_2d.priority = 50
	_player.global_position = player_position.global_position
	Dialogic.start("vulture_begining")
	await Dialogic.timeline_ended
	character_camera_2d.priority = 0
	interaction_ended.emit()
