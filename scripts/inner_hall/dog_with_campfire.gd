extends Node3D

@onready var hall_campfire: HallCampfire = $HallCampfire
@onready var spot_light_3d: SpotLight3D = $SpotLight3D

var _visible_called: bool


func _ready() -> void:
	spot_light_3d.light_energy = 0


func _on_visible_on_screen() -> void:
	if _visible_called:
		return	

	_visible_called = true
	await get_tree().create_timer(0.4).timeout
	hall_campfire.ignite()
	
	var tween: Tween = create_tween()
	tween.tween_property(spot_light_3d, "light_energy", 0.357, 0.5)
