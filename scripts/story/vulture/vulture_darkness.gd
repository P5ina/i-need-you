extends CanvasModulate


@export var vulture_player: Node2D
@export var darkness_start_y: float
@export var darkness_end_y: float


func _process(_delta: float) -> void:
	var vulture_y: float = vulture_player.global_position.y
	var darkness_range: float = darkness_end_y - darkness_start_y
	var darkness_progress: float = (vulture_y - darkness_start_y) / darkness_range
	darkness_progress = clampf(darkness_progress, 0.0, 1.0)
	color = Color.BLACK.lerp(Color.WHITE, darkness_progress)
