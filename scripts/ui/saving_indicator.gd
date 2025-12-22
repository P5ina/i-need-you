extends TextureRect


func _ready() -> void:
	SaveManager.saved.connect(_on_save)
	visible = false


func _on_save() -> void:
	visible = true
	modulate.a = 1.0
	var tween: Tween = create_tween()
	for i in range(3):
		tween.tween_property(self, "modulate:a", 0.4, 0.3)
		tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(self, "visible", false, 0.0)
