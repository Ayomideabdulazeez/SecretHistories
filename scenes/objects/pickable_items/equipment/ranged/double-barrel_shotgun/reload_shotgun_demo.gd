extends Spatial

export var shells_path : PackedScene

export var ejection_multiplier : float = 1.0

export (NodePath) var shell_position_holder_path
onready var shell_position_holder : Spatial = get_node(shell_position_holder_path) as Spatial
var shell_expell_vector : Vector3 = Vector3(0.2, 1.0, 0.3)

func expell_shells() -> void:
	print("Expelling shells")
	set_shell_position()


func set_shell_position() -> void:
	for shell_positions_node in shell_position_holder.get_children():
		if "Positions" in shell_positions_node.name:
			var shell_instance : Spatial = shells_path.instance() as Spatial
			add_child(shell_instance)
			shell_instance.global_transform.origin = shell_positions_node.global_transform.origin
			shell_instance.global_transform.basis = shell_positions_node.global_transform.basis
			add_impulse_to_shells(shell_instance, shell_positions_node.shell_impulse_value)


func add_impulse_to_shells(shell : RigidBody, impulse_value : Vector3) -> void:
	print("Adding impulse")
	shell.apply_impulse(shell.transform.origin, shell.transform.basis.xform(impulse_value) * ejection_multiplier)


func _on_reload_gun_pressed() -> void:
	$PlayerAnimationPlayer.play("double_barrel_reload")
#	$"%AnimationPlayer".play("reload")


func _on_expell_shells_pressed() -> void:
	expell_shells() 
