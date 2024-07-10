extends Node3D


@export var min_light := 1.000001
@export var max_light := PI
@export var light_start_duration := 2.0
@export var light_change_duration := 0.5
@export var light_move_duration := 0.5
@export var radius := 0.1

var is_on := false
var tween: Tween
var start_position: Vector3

@onready var fire_particles: GPUParticles3D = $FireParticles
@onready var fire_light: OmniLight3D = $FireLight
@onready var campfire_loop: AudioStreamPlayer = $CampfireLoop
@onready var campfire_ignite: AudioStreamPlayer = $CampfireIgnite


func _ready() -> void:
	fire_particles.emitting = false
	fire_light.light_energy = 0.0
	start_position = fire_light.position


func rand_light() -> float:
	return randf_range(min_light, max_light)


func rand_position() -> Vector3:
	return Vector3(randf(), 0, randf()).normalized() * radius


func _process(_delta: float) -> void:
	if is_on == false:
		return

	if not tween.is_running():
		tween = create_tween()
		tween.tween_property(fire_light, "light_energy", rand_light(), light_change_duration)
		tween.tween_property(fire_light, "position", start_position + rand_position(), light_move_duration)


func turn_on() -> void:
	is_on = true
	fire_particles.emitting = true

	tween = create_tween()
	tween.tween_property(fire_light, "light_energy", rand_light(), light_start_duration)

	campfire_ignite.play()
	campfire_loop.play()
