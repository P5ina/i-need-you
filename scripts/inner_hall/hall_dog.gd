extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func sit() -> void:
	animation_player.play("Root_M|Dog_GoldenRetriever_Sit|Animation Base Layer")


func stand() -> void:
	animation_player.play("Root_M|Dog_GoldenRetriever_Stand|Animation Base Layer")
	await animation_player.animation_finished
	animation_player.play("Root_M|Dog_GoldenRetriever_Idle|Animation Base Layer")
