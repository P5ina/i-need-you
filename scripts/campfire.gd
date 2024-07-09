extends Node3D


@export var min_light := 1.000001
@export var max_light := 2.999991
@export var light_start_duration := 2.0
@export var light_change_duration := 0.5

var is_on := false
var tween: Tween

@onready var fire_particles: GPUParticles3D = $FireParticles
@onready var fire_light: OmniLight3D = $FireLight
@onready var campfire_loop: AudioStreamPlayer = $CampfireLoop
@onready var campfire_ignite: AudioStreamPlayer = $CampfireIgnite


func _ready() -> void:
	fire_particles.emitting = false
	fire_light.light_energy = 0.0


func rand_light() -> float:
	return randf_range(min_light, max_light)


func _process(delta: float) -> void:
	if is_on == false:
		return

	if not tween.is_running():
		tween = create_tween()
		tween.tween_property(fire_light, "light_energy", rand_light(), light_change_duration)


func turn_on() -> void:
	is_on = true
	fire_particles.emitting = true

	tween = create_tween()
	tween.tween_property(fire_light, "light_energy", rand_light(), light_start_duration)

	campfire_ignite.play()
	campfire_loop.play()
