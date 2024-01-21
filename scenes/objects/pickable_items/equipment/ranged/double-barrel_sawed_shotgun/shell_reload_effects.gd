extends Node


export var impulse_position_1 : Vector3 = Vector3(0, 0.2, 0.1)
export var impulse_position_2 : Vector3 = Vector3(0, 0.2, 0.1)

var shotgun_shell = preload("res://scenes/objects/pickable_items/tiny/ammo/shotgun_shells/12-gauge_shotgun_shell.tscn")

var all_shell_positions : Array = []

onready var shell_position_1 = $"%ShellPosition1"
onready var shell_position_2 = $"%ShellPosition2"


func add_shells_to_slot() -> void:
	var added_new_shells = shotgun_shell.instance()
	for shells_positions in all_shell_positions:
		if shells_positions.get_child_count() < 1:
			shells_positions.add_child(added_new_shells)


func clear_all_slots() -> void:
	var added_new_shells = shotgun_shell.instance()
	for shells_positions in all_shell_positions:
		for bullet_shells in shells_positions.get_children():
			bullet_shells.queue_free()


func player_add_shell() -> void:
	owner.owner_character.player_gun_reload_shells.spawn_bullet_shells(shotgun_shell, Vector3(), Vector3())


func player_clear_shell() -> void:
	owner.owner_character.player_gun_reload_shells.clear_shotgun_shells()
