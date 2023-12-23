class_name BTGoToTarget
extends BTNode

# Move to currently selected target position


export var threshold : float = 0.5 setget set_threshold
var _thresold_squared : float = 0.25


func set_threshold(value : float):
	threshold = value
	_thresold_squared = value*value



func tick(state : CharacterState) -> int:
	var character = state.character

	if character.global_transform.origin.distance_squared_to(state.target_position) <= _thresold_squared:
		return Status.SUCCESS

	while state.path.size() > 0 and state.path[0].distance_squared_to(character.global_transform.origin) <= _thresold_squared:
		state.path.pop_front()

	if state.path.size() > 0:
		state.move_direction = state.path[0] - character.global_transform.origin
		state.face_direction = state.move_direction
		return Status.RUNNING

	return Status.FAILURE
