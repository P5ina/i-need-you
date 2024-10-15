extends Area2D

signal can_interact_changed(value: bool)

@export var ui_animation_duration: float

@onready var interaction_control: Control = $InteractionLayer/InteractionControl

var can_interact: bool:
	set(value):
		can_interact = value
		can_interact_changed.emit(value)

var _current_interaction: Interactable
var _avaliable_interaction_amount: int
var _tween: Tween

func _ready() -> void:
	interaction_control.modulate.a = 0


func _on_body_entered(body: Node2D) -> void:
	if not body.has_meta(Interactable.META_NAME):
		return
	_avaliable_interaction_amount += 1
	_update_can_interact()


func _on_body_exited(body: Node2D) -> void:
	if not body.has_meta(Interactable.META_NAME):
		return
	_avaliable_interaction_amount -= 1
	_update_can_interact()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	
	if _current_interaction:
		return
	
	for body in get_overlapping_bodies():
		if body.has_meta(Interactable.META_NAME):
			var interactable: Interactable = body.get_meta(Interactable.META_NAME)
			
			_current_interaction = interactable
			_current_interaction.interaction_ended.connect(stop_interacting)
			_current_interaction.interact(owner)
			_update_can_interact()
			return


func stop_interacting() -> void:
	_current_interaction.interaction_ended.disconnect(stop_interacting)
	_current_interaction = null
	
	_update_can_interact()


func _update_can_interact() -> void:
	var new_can_interact: bool = _avaliable_interaction_amount > 0
	if _current_interaction:
		new_can_interact = false
	
	can_interact = new_can_interact
	_update_ui(can_interact)


func _update_ui(should_show: bool) -> void:
	var alpha: float = 1. if should_show else 0.
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(interaction_control, "modulate:a",
		alpha, ui_animation_duration)
