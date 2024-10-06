class_name CharacterInteractable
extends Interactable


func interact(_player: CharacterBody2D) -> void:
	Dialogic.start("vulture_begining")
	await Dialogic.timeline_ended
	interaction_ended.emit()
