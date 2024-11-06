extends AnimationPlayer

@onready var campfire: StaticBody2D = $SortingNode/Campfire


func _ready() -> void:
	if not StoryState.intro_played:
		play(&"intro")
		await animation_finished
		StoryState.intro_played = true
		print("intro played")
	else:
		campfire.ignite(false)
