extends Spatial

export var shells_path : PackedScene
export var shells_path_2 : PackedScene



func expell_shells() -> void:
	print("Expelling shells")
	var instanced_shell = shells_path.instance()
	var instanced_shell_2 = shells_path_2.instance()
	set_shell_position(instanced_shell, instanced_shell_2)


func set_shell_position(instanced_shell_1 : RigidBody , instance_shell_2 : RigidBody) -> void:
	add_child(instanced_shell_1)
	add_child(instance_shell_2)
	
	instanced_shell_1.global_translation = $"%ShellExpellPositions".global_translation
	instance_shell_2.global_translation = $"%ShellExpellPositions2".global_translation
	instanced_shell_1.global_rotation = $"%ShellExpellPositions".global_rotation
	instance_shell_2.global_rotation = $"%ShellExpellPositions2".global_rotation
	
	add_impulse_to_shells(instanced_shell_1, instance_shell_2)


func add_impulse_to_shells(shell_1 : RigidBody, shell_2 : RigidBody) -> void:
	shell_1.apply_impulse(shell_1.global_translation, Vector3(0.2, 1.0, 0.6))
	shell_2.apply_impulse(shell_2.global_translation, Vector3(-0.2, 1.0, 0.6))


func _on_reload_gun_pressed() -> void:
	$PlayerAnimationPlayer.play("double_barrel_reload")
#	$"%AnimationPlayer".play("reload")


func _on_expell_shells_pressed() -> void:
	expell_shells() 
