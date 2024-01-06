class_name BTReloadGun extends BTAction


# If have appropriate ammo for currently equipped (mainhand) gun, reload it


signal character_reloaded   # For signalling speech


func _tick(state : CharacterState) -> int:
	var inventory = state.character.inventory
	var equipment = state.character.inventory.current_mainhand_equipment as GunItem

	for ammo_type in equipment.ammo_types:
		if inventory.tiny_items.has(ammo_type) and inventory.tiny_items[ammo_type] > 0:
			if equipment.current_ammo < 1:
				equipment.reload()
				emit_signal("character_reloaded")
				return BTResult.OK
	return BTResult.FAILED
