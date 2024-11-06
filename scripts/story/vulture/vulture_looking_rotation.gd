extends Sprite2D

const LOOK_DIRECTION_DOWN = 0
const LOOK_DIRECTION_DOWN_RIGHT = 1
const LOOK_DIRECTION_RIGHT = 2
const LOOK_DIRECTION_UP_RIGHT = 3
const LOOK_DIRECTION_UP = 4
const LOOK_DIRECTION_UP_LEFT = 5
const LOOK_DIRECTION_LEFT = 6
const LOOK_DIRECTION_DOWN_LEFT = 7

func _process(_delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(Gamemode.current_player.global_position)
	var angle: float = direction.angle()
	var new_frame: int = LOOK_DIRECTION_RIGHT

	if angle < deg_to_rad(-162):
		new_frame = LOOK_DIRECTION_LEFT
	elif angle < deg_to_rad(-126):
		new_frame = LOOK_DIRECTION_UP_LEFT
	elif angle < deg_to_rad(-54):
		new_frame = LOOK_DIRECTION_UP
	elif angle < deg_to_rad(-18):
		new_frame = LOOK_DIRECTION_UP_RIGHT
	elif angle < deg_to_rad(18):
		new_frame = LOOK_DIRECTION_RIGHT
	elif angle < deg_to_rad(54):
		new_frame = LOOK_DIRECTION_DOWN_RIGHT
	elif angle < deg_to_rad(126):
		new_frame = LOOK_DIRECTION_DOWN
	elif angle < deg_to_rad(162):
		new_frame = LOOK_DIRECTION_DOWN_LEFT
	else:
		new_frame = LOOK_DIRECTION_LEFT

	frame = new_frame
