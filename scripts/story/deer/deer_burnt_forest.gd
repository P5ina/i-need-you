extends Node2D

@onready var deer_player: CharacterBody2D = $DeerPlayer
@onready var fader: ColorRect = $CanvasLayer/ColorRect


func _ready() -> void:
	var movement: PlayerMovement = deer_player.get_meta(PlayerMovement.META_NAME)
	movement.movement_locked = true

	# Fade in from black
	var tween := create_tween()
	tween.tween_property(fader, "color:a", 0.0, 1.5)
	await tween.finished

	await get_tree().create_timer(1.5).timeout

	# Play laying down animation
	var anim: PlayerAnimation = deer_player.get_meta(PlayerAnimation.META_NAME)
	anim.animation_enabled = false
	anim.play("laying_down")
	await anim.animation_finished

	await get_tree().create_timer(3.0).timeout

	# Fade to black
	tween = create_tween()
	tween.tween_property(fader, "color:a", 1.0, 1.5)
	await tween.finished

	StoryState.set_character_state("deer", StoryState.CharacterState.CONVINCE)
	StoryLoader.load_back()
