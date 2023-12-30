extends Node


# Different hold states depending on the item equipped and the hand equipped on 
enum HoldStates {
	SMALL_GUN_ITEM,
	SMALL_GUN_ITEM_LEFT,
	LARGE_GUN_ITEM,
	MELEE_ITEM,
	ITEM_HORIZONTAL,
	ITEM_VERTICAL,
	ITEM_HORIZONTAL_LEFT,
	ITEM_VERTICAL_LEFT,
	SMALL_GUN_ADS,
	LARGE_GUNS_ADS,
	UNEQUIPPED
}


export var _cam_path : NodePath

var offhand_active = false
var mainhand_active = false
var is_on_ads = false

onready var inventory = $"../Inventory"
onready var arm_position = $"%MainCharOnlyArmsGameRig".translation
onready var _camera : ShakeCamera = get_node(_cam_path) as Camera
onready var animation_tree = $"%AnimationTree"
onready var gun_cam = $"../FPSCamera/ViewportContainer/Viewport/GunCam"

#signal inventory_changed
## Emitted to hide the HUD UI when player dies
#signal player_died
#
#signal unequip_mainhand
#signal unequip_offhand

func _ready():
	inventory.connect("inventory_changed", self, "_on_Inventory_inventory_changed")
	inventory.connect("unequip_mainhand", self, "_on_Inventory_unequip_mainhand")
	inventory.connect("unequip_offhand", self, "_on_Inventory_unequip_offhand")
#	inventory.connect("equip_offhand", self, "_on_Inventory_equip_offhand")


func _process(delta):
	if not $"..".is_reloading:   # TODO: messy
		pass


func _physics_process(delta):
	check_if_ads()


func check_player_animation():
	
	for bulky_item in owner.mainhand_equipment_root.get_children():
		if bulky_item.item_size == 2:
			animation_tree.set("parameters/Hand_Transition/current", 0)
			animation_tree.set("parameters/OffHand_MainHand_Blend/blend_amount", 1)
			animation_tree.set("parameters/Weapon_states/current", 0)
			animation_tree.set("parameters/Hold_Animation/current", 0)

			animation_tree.set("parameters/OffHand_Weapon_States/current", 0)
			animation_tree.set("parameters/Offhand_Hold_Animation/current", 0)
			adjust_arm(Vector3(0, -1.287, 0.063), 0.1)
			return
	### Off-hand item
	if inventory.current_offhand_equipment is GunItem:
		animation_tree.set("parameters/OffHand_Weapon_States/current", 1)
		
	elif inventory.current_offhand_equipment is EmptyHand:
		animation_tree.set("parameters/OffHand_Weapon_States/current", 2)
		
	elif inventory.current_offhand_equipment is EquipmentItem:
		if inventory.current_offhand_equipment.horizontal_holding == true:
			inventory.current_offhand_equipment.hold_position.rotation_degrees.z = -90
			animation_tree.set("parameters/Hand_Transition/current", 0)
			animation_tree.set("parameters/OffHand_Weapon_States/current", 0)
			animation_tree.set("parameters/Offhand_Hold_Animation/current", 1)
		else:
			animation_tree.set("parameters/Hand_Transition/current", 0)
			animation_tree.set("parameters/OffHand_MainHand_Blend/blend_amount", 1)
			animation_tree.set("parameters/OffHand_Weapon_States/current", 0)
			animation_tree.set("parameters/Offhand_Hold_Animation/current", 0)
	
	else:
		animation_tree.set("parameters/OffHand_Weapon_States/current", 2)
	
	### Main-hand item
	if inventory.current_mainhand_equipment is GunItem:
#		
		if inventory.current_mainhand_equipment.item_size == 0:
			animation_tree.set("parameters/Hand_Transition/current", 0)
			animation_tree.set("parameters/Weapon_states/current", 2)
		else:
			if inventory.current_mainhand_equipment.item_name == "Double-barrel shotgun":
				animation_tree.set("parameters/Hand_Transition/current", 0)
				animation_tree.set("parameters/OffHand_MainHand_Blend/blend_amount", 0)
				animation_tree.set("parameters/Weapon_states/current", 5)
			else:
				animation_tree.set("parameters/Hand_Transition/current", 0)
				animation_tree.set("parameters/OffHand_MainHand_Blend/blend_amount", 0)
				animation_tree.set("parameters/Weapon_states/current", 1)
			unequip_offhand()
	
	elif inventory.current_mainhand_equipment is EmptyHand:
		animation_tree.set("parameters/Hand_Transition/current", 0)
		animation_tree.set("parameters/Weapon_states/current", 4)


	elif inventory.current_mainhand_equipment is EquipmentItem:
		if inventory.current_mainhand_equipment.horizontal_holding == true:
			inventory.current_mainhand_equipment.hold_position.rotation_degrees.z = 90
			animation_tree.set("parameters/Hand_Transition/current", 0)
			animation_tree.set("parameters/Weapon_states/current", 0)
			animation_tree.set("parameters/Hold_Animation/current", 1)
		else:
			animation_tree.set("parameters/Hand_Transition/current", 0)
			animation_tree.set("parameters/Weapon_states/current", 0)
			animation_tree.set("parameters/Hold_Animation/current", 0)
	
	elif inventory.current_mainhand_equipment == null:
		animation_tree.set("parameters/Hand_Transition/current", 0)
		animation_tree.set("parameters/Weapon_states/current", 4)

	if inventory.current_mainhand_equipment and inventory.current_mainhand_equipment.item_size == 1:
		if inventory.current_mainhand_equipment is GunItem:
			adjust_arm(Vector3(0.008, -1.364, 0.175), 0.1)
		else:
			##This should be a melee item
			adjust_arm(Vector3(0, -1.280, 0.135), 0.1)
	elif inventory.current_mainhand_equipment and inventory.current_mainhand_equipment.item_size == 0:
		if not inventory.current_mainhand_equipment is MeleeItem:
			adjust_arm(Vector3(0, -1.287, 0.063), 0.1)
		else:
		##This should be a melee item
			adjust_arm(Vector3(0, -1.280, 0.135), 0.1)
	elif inventory.current_offhand_equipment and inventory.current_offhand_equipment.item_size == 0:
		adjust_arm(Vector3(0, -1.287, 0.063), 0.1)
		if not inventory.current_offhand_equipment is MeleeItem:
			adjust_arm(Vector3(0, -1.287, 0.063), 0.1)
		else:
		##This should be a melee item
			adjust_arm(Vector3(0, -1.280, 0.135), 0.1)

func unequip_offhand():
	inventory.unequip_offhand_item()


func check_if_ads():
	# This checks if the ADS mouse button is pressed then lerps the weapon to that position and when the button is released the weapon goes to its normal position
	if GameSettings.ads_hold_enabled:
		if Input.is_action_pressed("playerhand|main_use_secondary") and owner.do_sprint == false and owner.is_reloading == false:
			
			if inventory.current_mainhand_slot != null:
				if inventory.current_mainhand_equipment is GunItem:
					ads()
		
		else:
			if ((Input.is_action_just_released("playerhand|main_use_secondary") or owner.do_sprint == true or owner.is_reloading == true) and (inventory.current_mainhand_equipment is GunItem)):
				end_ads()
	
	else:   # ADS toggle mode
		if Input.is_action_just_pressed("playerhand|main_use_secondary") and owner.do_sprint == false and owner.is_reloading == false:
			
			if not is_on_ads and owner.do_sprint == false:
				if inventory.current_mainhand_slot != null:
					if inventory.current_mainhand_equipment is GunItem:
						ads()
			
			else:
				if (inventory.current_mainhand_equipment is GunItem or (owner.do_sprint == true and inventory.current_mainhand_equipment is GunItem)):
					end_ads()


func ads():
	operation_tween(
	inventory.current_mainhand_equipment.hold_position, "rotation_degrees", 
	inventory.current_mainhand_equipment.hold_position.rotation_degrees, 
	inventory.current_mainhand_equipment.ads_hold_rotation, 0.0
)
	operation_tween(
	inventory.current_mainhand_equipment.hold_position, "translation", 
	inventory.current_mainhand_equipment.hold_position.translation, 
	inventory.current_mainhand_equipment.ads_hold_position, 0.0
)
	if inventory.current_mainhand_equipment.item_size == 0:
		operation_tween(animation_tree, 
		"parameters/SmallAds/blend_amount", 
		animation_tree.get("parameters/SmallAds/blend_amount"),1.0, 0.1)
		_camera.fov = lerp(_camera.fov, 65, 0.1)
		adjust_arm(Vector3(-0.086, -1.558, 0.294), 0.1)
		
	else:
		if inventory.current_mainhand_equipment.item_name == "Double-barrel shotgun":
			operation_tween(animation_tree,
			"parameters/ShotgunAds/blend_amount",
			animation_tree.get("parameters/ShotgunAds/blend_amount"), 1.0, 0.05)
		else:
			operation_tween(animation_tree,
			"parameters/MediumAds/blend_amount",
			animation_tree.get("parameters/MediumAds/blend_amount"), 1.0, 0.05)
		_camera.fov = lerp(_camera.fov, 60, 0.04)
		adjust_arm(Vector3(-0.054, -1.571, 0.257), 0.04)


func end_ads():
	operation_tween(
	inventory.current_mainhand_equipment.hold_position, "rotation_degrees", 
	inventory.current_mainhand_equipment.hold_position.rotation_degrees, 
	inventory.current_mainhand_equipment.ads_reset_rotation, 0.1
)
	operation_tween(
	inventory.current_mainhand_equipment.hold_position, "translation", 
	inventory.current_mainhand_equipment.hold_position.translation, 
	inventory.current_mainhand_equipment.ads_reset_position, 0.1
)
	
	if inventory.current_mainhand_equipment.item_size == 0:
		operation_tween(
		animation_tree,
		"parameters/SmallAds/blend_amount",
		animation_tree.get("parameters/SmallAds/blend_amount"), 0.0, 0.1)
		
		adjust_arm(Vector3(0, -1.287, 0.063), 0.1)
	else:
		if inventory.current_mainhand_equipment.item_name == "Double-barrel shotgun":
			operation_tween(animation_tree,
			"parameters/ShotgunAds/blend_amount",
			animation_tree.get("parameters/ShotgunAds/blend_amount"), 0.0, 0.05)
		else:
			operation_tween(animation_tree,
			"parameters/MediumAds/blend_amount",
			animation_tree.get("parameters/MediumAds/blend_amount"), 0.0, 0.05)
		adjust_arm(Vector3(0.008, -1.364, 0.175), 0.1)
	_camera.fov = lerp(_camera.fov, 70, 0.1)


func reload_weapons():
	if get_available_gun().item_size == 0:
		unequip_offhand()
	
	get_available_gun().animation_player.play("reload")
	player_reload()
	yield(get_tree().create_timer(get_available_gun().animation_player.get_animation("reload").length - 0.3), "timeout")
	if get_available_gun().item_size == 0:
		inventory.equip_offhand_item()
		yield(get_tree().create_timer(0.5), "timeout")
	check_player_animation()


func player_reload():
	adjust_arm(Vector3(0.008, -1.364, 0.175), 0.1)
	animation_tree.set("parameters/OffHand_MainHand_Blend/blend_amount", 0)
	animation_tree.set("parameters/" + str(get_available_gun().item_name) + "/active", true)


func get_available_gun() -> EquipmentItem:
	return inventory.current_mainhand_equipment


func get_available_offhand_item() -> EquipmentItem:
	return inventory.current_offhand_equipment


func operation_tween(object : Object, method, tweening_from, tweening_to, duration):
	var tweener = Tween.new() as Tween
	tweener.interpolate_property(object, method, tweening_from, tweening_to, duration, Tween.TRANS_LINEAR)
	add_child(tweener)
	tweener.start()


func adjust_arm(final_position, interpolation_value):
	$"%ADSTween".interpolate_property($"%MainCharOnlyArmsGameRig", "translation", $"%MainCharOnlyArmsGameRig".translation, final_position, interpolation_value)
	$"%ADSTween".start()


func _on_Inventory_inventory_changed():
	$"%AnimationTree".set("parameters/MeleeSpeed/scale", 1)
	print("Equipped new item")
	yield(get_tree().create_timer(0.5), "timeout")
	check_player_animation()


func switch_mainhand_item_animation():
	$"%AnimationTree".set("parameters/MeleeSpeed/scale", 1)
	animation_tree.set("parameters/Hand_Transition/current",0)
	animation_tree.set("parameters/OffHand_MainHand_Blend/blend_amount",1)
	animation_tree.set("parameters/Weapon_states/current",4)
	
	yield(get_tree().create_timer(0.5), "timeout")
	check_player_animation()


func _on_Inventory_unequip_mainhand():
	$"%AnimationTree".set("parameters/MeleeSpeed/scale", 1)
	animation_tree.set("parameters/Hand_Transition/current", 0)
	animation_tree.set("parameters/OffHand_MainHand_Blend/blend_amount", 1)
	animation_tree.set("parameters/Weapon_states/current", 4)


func _on_Inventory_unequip_offhand():
	$"%AnimationTree".set("parameters/MeleeSpeed/scale", 1)
	animation_tree.set("parameters/OffHand_Weapon_States/current", 2)
