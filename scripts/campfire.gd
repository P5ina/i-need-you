extends Node2D


@export var min_light: float = 3
@export var max_light: float = 4
@export var light_start_duration := 2.0
@export var light_change_duration := 0.5

var is_on: bool = false
var tween: Tween

@onready var fire_light: PointLight2D = $FireLight
@onready var campfire_sprite: AnimatedSprite2D = $CampfireSprite
@onready var campfire_loop: AudioStreamPlayer2D = $CampfireLoopSound
@onready var campfire_ignite: AudioStreamPlayer2D = $CampfireIgniteSound


func _ready() -> void:
	fire_light.energy = 0.0
	campfire_sprite.play(&"unlit")
	await get_tree().create_timer(2.).timeout
	ignite()

func rand_light() -> float:
	return randf_range(min_light, max_light)


func _process(_delta: float) -> void:
	if is_on == false:
		return

	if not tween.is_running():
		tween = create_tween()
		tween.tween_property(fire_light, "energy", rand_light(), light_change_duration)


func ignite() -> void:
	is_on = true

	tween = create_tween()
	tween.tween_property(fire_light, "energy", rand_light(), light_start_duration)
	campfire_sprite.play(&"lit")

	campfire_ignite.play()
	campfire_loop.play()
