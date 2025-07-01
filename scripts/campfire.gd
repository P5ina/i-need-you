class_name Campfire
extends Node2D


@export var min_light: float = 3
@export var max_light: float = 4
@export var light_start_duration := 2.0
@export var light_change_duration := 0.5
@export var ignite_from_start: bool = false

var is_on: bool = false
var tween: Tween

@onready var fire_light: PointLight2D = $FireCenter/FireLight
@onready var fire_center: Node2D = $FireCenter
@onready var campfire_sprite: AnimatedSprite2D = $CampfireSprite
@onready var fire_sprite: AnimatedSprite2D = $FireSprite
@onready var campfire_loop: AudioStreamPlayer2D = $CampfireLoopSound
@onready var campfire_ignite: AudioStreamPlayer2D = $CampfireIgniteSound


func _ready() -> void:
	fire_light.energy = 0.0
	campfire_sprite.play(&"unlit")
	fire_sprite.play(&"unlit")
	if ignite_from_start:
		ignite()

func rand_light() -> float:
	return randf_range(min_light, max_light)


func _process(_delta: float) -> void:
	if is_on == false:
		return

	if not tween.is_running():
		tween = create_tween()
		tween.tween_property(fire_light, "energy", rand_light(), light_change_duration)
		


func ignite(play_ignite_sound: bool = true) -> void:
	is_on = true

	tween = create_tween()
	tween.tween_property(fire_light, "energy", rand_light(), light_start_duration)

	var spin_tween := create_tween().set_loops()
	spin_tween.tween_property(fire_center, "rotation", PI * 2, 8.0).from(0.0)
	spin_tween.tween_property(fire_center, "rotation", PI, 6.0)
	spin_tween.tween_property(fire_center, "rotation", PI * 2.0, 6.0)

	campfire_sprite.play(&"lit")
	fire_sprite.play(&"lit")

	if play_ignite_sound:
		campfire_ignite.play()
	campfire_loop.play()
