class_name AIMemory extends Node

## AIMemory stores KNOWLEDGE about the world and player which is leveraged by a FSM to make 
## decisions and carry out actions based on that knowledge. The intention is for can_see_target to
## be set by a detection Link, then target_last_known_position is used by States; the exception to
## this is Links which may need to access target_character.global_position directly 

@export var debug_mode:bool = false ## Shows the target last known position
## The number of seconds following a sound event where the enemy still "hears" the target
@export var hearing_time_threshold:float = 1

# -------------- SELF VARS --------------
var initial_position:Vector3 ## Set by my_character
## The center of the wander state for this AI. Setting it here so we can remember it when we transition
## in and out of wander states
var wander_center : Vector3
var use_attack_state_delay:bool = false ## Set by Links; read by AttackStates

# -------------- TARGET VARS --------------
var target_character:Character ## Recursively set by the level
var target_last_known_position:Vector3 ## Set by self every phys frame that target_seen is true
var can_see_target:bool = false: ## Set by target detection Links 
	set(val):
		can_see_target = val
		if can_see_target:
			update_target_position()
## In ms since engine start. Updates target_last_known_position whenever set
var target_last_heard_time:float = 0
var target_just_heard:bool = false: ## Set by Enemy, used/consumed by Links
	get:
		var within_threshold:bool = Time.get_ticks_msec() - target_last_heard_time < hearing_time_threshold * 1000.0
		if within_threshold:
			return target_just_heard
		return false


func _physics_process(delta):
	if target_character and can_see_target:
		update_target_position()
	
	if debug_mode:
		$MeshInstance3D.show()
		$MeshInstance3D.global_position = target_last_known_position


func update_target_position() -> void:
	target_last_known_position = target_character.global_position


## TODO: change this to check that the sound originated from the target if AI needs to react to sounds
## from other sources such as grenades, other enemies, etc.
func on_target_heard(sound_position:Vector3) -> void:
	#DebugMaster.log_debug("Heard sound at " + str(sound_position))
	target_just_heard = true
	target_last_heard_time = Time.get_ticks_msec()
	target_last_known_position = sound_position
