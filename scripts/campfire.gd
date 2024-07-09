extends Node3D


@export var min_light := 1.000001
@export var max_light := 2.999991
@export var light_start_duration := 2.0
@export var light_change_duration := 0.5

var is_on := false
var tween : Tween

@onready var fire_particles : GPUParticles3D = $FireParticles
@onready var fire_light : OmniLight3D = $FireLight


func _ready() -> void:
	fire_particles.emitting = false
	fire_light.light_energy = 0.0
	turn_on()


func rand_light() -> float:
	return randf_range(min_light, max_light)


func _process(delta: float) -> void:
	if is_on == false:
		return
	if tween.is_running():
		return
	tween = create_tween()
	tween.tween_property(fire_light, "light_energy", rand_light(), light_change_duration)


func turn_on() -> void:
	is_on = true
	fire_particles.emitting = true
	tween = create_tween()
	tween.tween_property(fire_light, "light_energy", rand_light(), light_start_duration)
