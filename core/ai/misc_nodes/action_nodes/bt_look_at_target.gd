class_name BTLookAtTarget extends BTAction


# Turn towards target position
# TODO: eventually, turn the head towards it, a bit faster than body


func _tick(state : CharacterState) -> int:
	# This sets the target facing direction, and immediately exits.
	# Note that the character may not be facing in the given direction yet
	# When this node succeeds
	state.face_direction = state.target_position - state.character.global_transform.origin
	return BTResult.OK
