class_name BTGunCooldown extends BTCheck


# Checks if the gun (in the mainhand) is on cooldown


func _tick(state : CharacterState) -> int:
	var equipment = state.character.inventory.current_mainhand_equipment as GunItem
	if equipment: return BTResult.RUNNING if equipment.on_cooldown or state.character.is_reloading else BTResult.OK
	return BTResult.FAILED
