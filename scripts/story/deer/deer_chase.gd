extends Node2D

const CHASE_MUSIC := preload("res://sounds/stories/deer/DOORS ORIGINAL SOUNDTRACK VOL. 1 - Here I Come.mp3")
const BURNT_FOREST_SCENE := "res://scenes/stories/deer/deer_burnt_forest.tscn"

@export var fire_zone: Area2D
@export var fire_escape_y: float = -2000.0

@onready var deer_player: CharacterBody2D = $DeerPlayer
@onready var music: AudioStreamPlayer = $Music

var _escaped: bool = false


func _ready() -> void:
	var movement: PlayerMovement = deer_player.get_meta(PlayerMovement.META_NAME)
	movement.is_running = true
	movement.movement_locked = false

	fire_zone.set("movement_enabled", true)

	music.stream = CHASE_MUSIC
	music.play()


func _process(_delta: float) -> void:
	if _escaped:
		return
	if deer_player.global_position.y <= fire_escape_y:
		_player_escaped()


func _player_escaped() -> void:
	_escaped = true
	var movement: PlayerMovement = deer_player.get_meta(PlayerMovement.META_NAME)
	movement.movement_locked = true
	fire_zone.set("movement_enabled", false)
	SceneLoader.transit_to_scene(BURNT_FOREST_SCENE)
