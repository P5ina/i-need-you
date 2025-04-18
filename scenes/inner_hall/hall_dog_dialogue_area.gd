extends Area3D

@onready var interaction_control: Control = $InteractionLayer/InteractionControl
@onready var action_label: Label = $InteractionLayer/InteractionControl/HBoxContainer/ActionLabel
@onready var key_label: Label = $InteractionLayer/InteractionControl/HBoxContainer/KeyboardButtonPanel/KeyLabel

@onready var dog: Node3D = $"../Dog"
@onready var phantom_camera_3d: PhantomCamera3D = $"../PhantomCamera3D"

var _tween: Tween
var _in_area: bool
var _player: CharacterBody3D

func _ready() -> void:
	interaction_control.modulate.a = 0


func _on_body_entered(body: Node3D) -> void:
	if body is not CharacterBody3D:
		return
	_in_area = true
	_player = body
	_update_ui(true)


func _on_body_exited(body: Node3D) -> void:
	if body is not CharacterBody3D:
		return
	_in_area = false
	_player = null
	_update_ui(false)


func _update_ui(should_show: bool) -> void:
	var alpha: float = 1. if should_show else 0.
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(interaction_control, "modulate:a", alpha, 0.2)


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	if not _in_area:
		return
	
	if Dialogic.current_timeline != null:
		return
	
	_interact()


func _interact() -> void:
	Dialogic.start("dog_memory_hall")
	_update_ui(false)
	dog.sit()
	phantom_camera_3d.priority = 2
	_player.movement_locked = true
	_player.view_locked = true

	await Dialogic.timeline_ended

	_update_ui(true)
	dog.stand()
	phantom_camera_3d.priority = 0
	_player.movement_locked = false
	_player.view_locked = false
