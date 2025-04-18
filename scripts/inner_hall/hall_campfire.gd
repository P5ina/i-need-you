class_name HallCampfire
extends Node3D


@export var min_light: float = 3
@export var max_light: float = 4
@export var light_start_duration := 2.0
@export var light_change_duration := 0.5
@export var ignite_from_start: bool = false

var is_on: bool = false
var tween: Tween

@onready var fire_light: OmniLight3D = $FireLight
@onready var fire_particles: GPUParticles3D = $FireParticles
@onready var campfire_loop: AudioStreamPlayer3D = $CampfireLoopSound
@onready var campfire_ignite: AudioStreamPlayer3D = $CampfireIgniteSound


func _ready() -> void:
	fire_light.light_energy = 0.0
	fire_particles.emitting = false
	if ignite_from_start:
		ignite()

func rand_light() -> float:
	return randf_range(min_light, max_light)


func _process(_delta: float) -> void:
	if is_on == false:
		return

	if not tween.is_running():
		tween = create_tween()
		tween.tween_property(fire_light, "light_energy", rand_light(), light_change_duration)


func ignite(play_ignite_sound: bool = true) -> void:
	is_on = true
	fire_particles.emitting = true

	tween = create_tween()
	tween.tween_property(fire_light, "light_energy", rand_light(), light_start_duration)

	if play_ignite_sound:
		campfire_ignite.play()
	campfire_loop.play()
