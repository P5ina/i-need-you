extends VBoxContainer

@export var appear_duration: float = 1.0
@export var appear_delay: float = 0.3


func _ready() -> void:
	for child in get_children():
		child.visible = false
		child.modulate.a = 0.0


func show_options() -> void:
	for child in get_children():
		child.visible = true
		var tween: Tween = child.create_tween()
		tween.tween_property(child, "modulate:a", 1.0, appear_duration)
		await get_tree().create_timer(appear_delay).timeout
	$PlayButton.grab_focus()
