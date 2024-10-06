extends Node2D

#@onready var campfire_camera: PhantomCamera2D = $CampfireCamera
#@onready var player_camera: PhantomCamera2D = $PlayerCamera


func _ready() -> void:
	if not StoryState.intro_played:
		pass
