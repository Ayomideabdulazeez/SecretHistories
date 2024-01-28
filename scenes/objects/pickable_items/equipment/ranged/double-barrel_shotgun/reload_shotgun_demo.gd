extends Spatial

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
			add_child(shell_instance)
			shell_instance.global_translation = shell_positions_node.global_translation
			shell_instance.global_rotation = shell_positions_node.global_rotation
			add_impulse_to_shells(shell_instance)


func add_impulse_to_shells(shell : Spatial) -> void:
	shell.apply_impulse(shell.global_translation, Vector3(0.2, 1.0, 0.3) * ejection_multiplier)
#	shell_2.apply_impulse(shell_2.global_translation, Vector3(-0.2, 1.0, 0.3) * ejection_multiplier)


func _on_reload_gun_pressed() -> void:
	$PlayerAnimationPlayer.play("double_barrel_reload")
#	$"%AnimationPlayer".play("reload")


func _on_expell_shells_pressed() -> void:
	expell_shells() 
