extends StaticBody2D

@onready var falling_tree_sprite: AnimatedSprite2D = $FallingTreeSprite
@onready var fallen_tree_sprite: AnimatedSprite2D = $FallenTreeSprite

var fallen: bool

func _ready() -> void:
	falling_tree_sprite.modulate.a = 1.0
	fallen_tree_sprite.modulate.a = 0.0


func _on_screen_entered() -> void:
	if fallen:
		return
	fallen = true
	falling_tree_sprite.play("default")
	var tween := create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(falling_tree_sprite, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(fallen_tree_sprite, "modulate:a", 1.0, 0.2)
