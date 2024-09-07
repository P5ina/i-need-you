class_name Interactable
extends Node

const META_NAME = &"InteractableComponent";


func _ready() -> void:
	owner.set_meta(META_NAME, self)


func interact(player: CharacterBody2D) -> void:
	push_error("Unimplemented interact method")
