extends Node

export var shells_path : PackedScene

export var ejection_multiplier : float = 1.0

export (NodePath) var shell_position_holder_path
onready var shell_position_holder : Spatial = get_node(shell_position_holder_path) as Spatial


func expell_shells() -> void:
	print("Expelling shells")
	set_shell_position()


func set_shell_position() -> void:
	for shell_positions_node in shell_position_holder.get_children():
		if "Positions" in shell_positions_node.name:
			var shell_instance : Spatial = shells_path.instance() as Spatial
			var world_scene
			if is_instance_valid(GameManager.game):
				world_scene = GameManager.game
			else:
				world_scene = owner.owner_character.owner as Spatial
			
			world_scene.add_child(shell_instance)
			shell_instance.global_translation = shell_positions_node.global_translation
			shell_instance.global_rotation = shell_positions_node.global_rotation
			add_impulse_to_shells(shell_instance)


func add_impulse_to_shells(shell : Spatial) -> void:
	shell.apply_impulse(shell.global_translation, Vector3(0.2, 1.0, 0.3) * ejection_multiplier)
#	shell_2.apply_impulse(shell_2.global_translation, Vector3(-0.2, 1.0, 0.3) * ejection_multiplier)



func add_shells_to_slot() -> void:
	var added_new_shells = shells_path.instance()
	for shells_positions_node in shell_position_holder.get_children():
		if "Positions" in shells_positions_node.name:
			if shells_positions_node.get_child_count() < 1:
				shells_positions_node.add_child(added_new_shells)


func clear_all_slots() -> void:
	for shells_positions_node in shell_position_holder.get_children():
		if "Positions" in shells_positions_node.name:
			for bullet_shells in shells_positions_node.get_children():
				bullet_shells.queue_free()


func player_add_shell() -> void:
	owner.owner_character.player_gun_reload_shells.spawn_bullet_shells(shells_path, Vector3(), Vector3())


func player_clear_shell() -> void:
	owner.owner_character.player_gun_reload_shells.clear_shotgun_shells()
