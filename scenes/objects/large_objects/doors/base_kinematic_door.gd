extends Spatial
class_name BaseKinematicDoor

#
# This is a simplified door model, with toggle open/close
# Done due to limitations in Godot 3 making it difficult to implement
# a fully simulated Rigid Body door
#


enum DoorState {
	OPEN,
	CLOSED,
	AUTO_CLOSING,
	STUCK,
	BROKEN
}

export var health : float = 75.0

var broken_door_scene : PackedScene = preload("res://scenes/objects/large_objects/doors/base_broken_door.tscn")

var navigation_areas : Array
var door_state : int = DoorState.CLOSED setget set_door_state

var door_move_time : float = 0.5
var door_open_angle : float = deg2rad(100)
var door_close_threshold : float = deg2rad(5)
var door_speed : float = door_open_angle/door_move_time
var door_auto_close_speed : float = 0.05*door_speed
var door_auto_close_delay_min : float = 25.0
var door_auto_close_delay_max : float = 55.0
var door_should_move : float = false
var door_stuck_on_close_probability = 0.01   # TODO make this optional in settings menu
var time_to_auto_close = 0.0

onready var door_body = $"%DoorBody"
onready var door_hinge_z_axis = $"%DoorHingeZAxis"
onready var open_block_detector = $"%OpenBlockDetector"
onready var close_block_detector = $"%CloseBlockDetector"
onready var doorway_gaps_filler = $"%DoorwayGapsFiller"
onready var npc_detector = $"%NpcDetector"
onready var npc_check_timer: Timer = $NpcCheckTimer
onready var broken_door_origin: Spatial = $"%BrokenDoorOrigin"
onready var navigation: Navigation = $Navigation

onready var door_open_sound : AudioStreamPlayer3D = $Sounds/DoorOpen
onready var door_close_sound : AudioStreamPlayer3D = $Sounds/DoorClose
onready var door_shake_sound : AudioStreamPlayer3D = $Sounds/DoorShakeSound
onready var door_kick_ineffective_sound : AudioStreamPlayer3D = $Sounds/DoorKickIneffectiveSound
onready var door_kick_effective_sound : AudioStreamPlayer3D = $Sounds/DoorKickEffectiveSound
onready var door_break_sound : AudioStreamPlayer3D = $Sounds/DoorBreakSound


func _physics_process(delta):
	match door_state:
		DoorState.OPEN:
			# Delay auto closing if a character is nearby
			if npc_detector.get_overlapping_bodies().size() > 0:
				reset_auto_close_timer()
			time_to_auto_close -= delta
			if time_to_auto_close <= 0.0:
				self.door_state = DoorState.AUTO_CLOSING
			if door_hinge_z_axis.rotation.y < door_open_angle and door_should_move:
				for obstacle in open_block_detector.get_overlapping_bodies():
					if not obstacle in [door_body, doorway_gaps_filler]:
						door_should_move = false
						if door_hinge_z_axis.rotation.y < door_close_threshold:
							self.door_state = DoorState.CLOSED
							door_should_move = true
						return
				door_hinge_z_axis.rotation.y = move_toward(door_hinge_z_axis.rotation.y, door_open_angle, door_speed * delta)
		DoorState.CLOSED, DoorState.AUTO_CLOSING:
			if door_hinge_z_axis.rotation.y > 0.0 and door_should_move:
				for obstacle in close_block_detector.get_overlapping_bodies():
					if not obstacle in [door_body, doorway_gaps_filler]:
						door_should_move = false
						if door_hinge_z_axis.rotation.y > door_close_threshold:
								self.door_state = DoorState.OPEN
								if door_hinge_z_axis.rotation.y > door_open_angle - door_close_threshold:
									door_should_move = true
						return
				var close_speed = door_speed if door_state == DoorState.CLOSED else door_auto_close_speed
				door_hinge_z_axis.rotation.y = move_toward(door_hinge_z_axis.rotation.y, 0.0, close_speed * delta)
				door_should_move = door_hinge_z_axis.rotation.y > 0
				if not door_should_move:
					# This is when the door actually closes
					# TODO: play a sound?
					if fposmod(randf(), 1.0) < door_stuck_on_close_probability:
						self.door_state = DoorState.STUCK
				
		DoorState.STUCK:
			door_should_move = false
			pass


func set_door_state(value : int):
	if door_state != value:
		if value == DoorState.OPEN:
			reset_auto_close_timer()
	door_state = value


func reset_auto_close_timer():
	time_to_auto_close = rand_range(door_auto_close_delay_min, door_auto_close_delay_max)


func break_door(position, impulse, damage):
	door_state = DoorState.BROKEN
	door_break_sound.play()
	var global_door_transform = broken_door_origin.global_transform
	
	door_hinge_z_axis.queue_free()
	npc_detector.queue_free()
	npc_check_timer.queue_free()
	navigation.queue_free()
	
	var broken_door_instance : Spatial = broken_door_scene.instance()
	broken_door_instance.transform = global_transform.affine_inverse() * global_door_transform
	add_child(broken_door_instance)
	broken_door_instance.apply_impulse(position, impulse * (damage / 5.0), 0.0)


func _on_Interactable_character_interacted(character):
	match door_state:
		DoorState.CLOSED, DoorState.AUTO_CLOSING:
			self.door_state = DoorState.OPEN
			door_should_move = true
			door_close_sound.stop()
			if !door_open_sound.playing:
				door_open_sound.play()
		
		DoorState.OPEN:
			self.door_state = DoorState.CLOSED
			door_should_move = true
			door_open_sound.stop()
			if !door_close_sound.playing:
				door_close_sound.play()
		
		DoorState.STUCK:
			if !door_shake_sound.playing:
				door_shake_sound.play()


# TODO: Shooting doors not currently working
#func damage(damage_amount, damage_type, target):
#	if damage_amount < 10:
#		door_kick_ineffective_sound.play()
#	else:
#		door_kick_effective_sound.play()
#	health -= damage_amount
#	print("Door health : ", health)
#	if health <= 0:
#		break_door()


func _on_Interactable_kicked(position, impulse, damage) -> void:
	health -= damage
	door_kick_effective_sound.play()
	print("Door health : ", health)
	if health <= 0:
		break_door(position, impulse, damage)


func _on_NpcDetector_body_entered(body):
	if not body is Player:
		if door_state == DoorState.CLOSED or door_state == DoorState.AUTO_CLOSING:
			door_state = DoorState.OPEN
			door_should_move = true


func _on_NpcCheckTimer_timeout():
	for body in npc_detector.get_overlapping_bodies():
		if not body is Player:
			if door_state == DoorState.CLOSED or door_state == DoorState.AUTO_CLOSING:
				door_state = DoorState.OPEN
				door_should_move = true
				return
