extends AudioStreamPlayer2D

@export var distance_for_sound: float = 30.0

var moved_distance: float

func _physics_process(_delta: float) -> void:
	var body: CharacterBody2D = owner
	var velocity: float = body.get_position_delta().length()
	moved_distance += velocity
	if moved_distance > distance_for_sound:
		moved_distance = 0
		play()
