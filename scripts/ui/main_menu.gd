extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var menu_options: VBoxContainer = $CanvasLayer/MainMenuScreen/MenuOptions
@onready var main_menu_campfire: Campfire = $MainMenuCampfire
@onready var wush_sound_player: AudioStreamPlayer = $WushSound
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar

@export var play_wush: bool
@export var need_to_press: int

var pressed: int

func _input(event: InputEvent) -> void:
	if not play_wush:
		return
	
	if event.is_action_pressed("ui_accept"):
		pressed += 1
		progress_bar.value = pressed
		if need_to_press <= pressed:
			animation_player.play("RESET")
			menu_options.show_options_immediately()
			main_menu_campfire.ignite()
			wush_sound_player.play()
			progress_bar.hide()
			play_wush = false
