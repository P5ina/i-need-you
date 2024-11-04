extends Polygon2D

@export var spawn_distance: int = 40

@onready var vulture_looking_scene: PackedScene = preload("res://scenes/stories/vulture_looking.tscn")

func _ready() -> void:
	var points: PackedVector2Array = PoissonDiscSampling.generate_points_for_polygon(polygon, spawn_distance, 10)
	for point in points:
		var vulture_looking: Node2D = vulture_looking_scene.instantiate()
		vulture_looking.position = point
		add_child(vulture_looking)
