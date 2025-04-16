extends Node

signal transition_finished

@export var fade_duration: float
@export var black_screen_delay: float

@onready var fader: ColorRect = $CanvasLayer/Fader

var tween: Tween
var current_loading_file: String


func _ready() -> void:
	fader.visible = false
	fader.modulate.a = 0.0


func transit_to_scene(scene_path: String) -> void:
	if tween and tween.is_running():
		return
	print("Going to scene: ", scene_path)
	tween = create_tween()
	fader.visible = true
	tween.tween_property(fader, "modulate:a", 1.0, fade_duration)
	tween.tween_callback(_start_loading_scene.bind(scene_path))
	tween.tween_interval(black_screen_delay)


func _start_loading_scene(scene_path: String) -> void:
	var state: Error = ResourceLoader.load_threaded_request(scene_path)
	if state == OK:
		current_loading_file = scene_path
		set_process(true)


func _process(_delta: float) -> void:
	var load_status: ResourceLoader.ThreadLoadStatus = \
		ResourceLoader.load_threaded_get_status(current_loading_file)
	match load_status:
		0, 2:
			set_process(false)
			return
		1:
			pass
		3:
			var loaded_scene: PackedScene = ResourceLoader.load_threaded_get(current_loading_file)
			
			if tween and tween.is_running():
				await tween.finished
			get_tree().change_scene_to_packed(loaded_scene)
			set_process(false)
			tween = create_tween()
			tween.tween_property(fader, "modulate:a", 0.0, fade_duration)
			tween.tween_callback(fader.set_visible.bind(false))
			await tween.finished
			transition_finished.emit()
