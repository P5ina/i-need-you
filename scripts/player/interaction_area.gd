extends Area2D

func _ready() -> void:
	assert(owner is CharacterBody2D)


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	
	for body in get_overlapping_bodies():
		if body.has_meta(Interactable.META_NAME):
			var interactable: Interactable = body.get_meta(Interactable.META_NAME)
			interactable.interact(owner)
