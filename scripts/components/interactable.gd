class_name Interactable
extends Node

const META_NAME = &"InteractableComponent"

@export var action_name: String = "Interact"


func _ready() -> void:
	owner.set_meta(META_NAME, self)


func interact(_player: CharacterBody2D) -> void:
	push_error("Unimplemented interact method")