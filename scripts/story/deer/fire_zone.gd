extends Area2D

@export var move_speed: float
@export var distance_threshold: float
@export var movement_enabled: bool

@export var deer: Node2D


func _process(delta: float) -> void:
	if movement_enabled:
		move(delta)


func move(delta: float) -> void:
	var distance := position.y - deer.position.y
	if distance > distance_threshold:
		position.y = deer.position.y + distance_threshold
	position.y -= move_speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body == deer:
		deer.get_meta(PlayerMovement.META_NAME).movement_locked = true
		SceneLoader.transit_to_scene("res://scenes/stories/deer/deer_story.tscn")
