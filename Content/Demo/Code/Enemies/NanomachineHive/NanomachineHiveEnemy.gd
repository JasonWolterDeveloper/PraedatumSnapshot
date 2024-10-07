class_name NanomachineHive extends Enemy


@onready var nanomachine_hive_aesthetics : Node3D = $LookStuff/NanomachineHiveAesthetics

@onready var nanomachine_activation_timer : Timer = $NanomachineActivationTImer
@export var nanomachine_activation_time : float = 0.5
@export var nanomachine_deactivation_time : float = 0.2
var timer_active : bool = false

@export var wage_cage_gibs_scene : PackedScene

@onready var player_detected_bark : BarkType = $NanomachinePlayerDetectedBark

## Determines whether or not the nanomachines for this hive are actually active
## which determines in turn whether or not the enemy can actually attack. This is 
## special for the Nanomachine Hive to essentially allow the player to sneak up on them
## without taking damage and to make them look cool
var nanomachines_active : bool = false


# Tells the AimingMaster we're a melee enemy
func is_unarmed():
	return true


func target_detected_bark() -> void:
	player_detected_bark.emit_bark()


func on_nanomachines_activated():
	nanomachines_active = true
	timer_active = false


## Activate the nanomachines. This effect takes time
## for them to fade in and is not instant
func activate_nanomachines():
	# We only want to reactivate if we're currently un activated
	if not nanomachines_active and not timer_active:
		nanomachine_activation_timer.start(nanomachine_activation_time)
		timer_active = true
		nanomachine_hive_aesthetics.activate_nanomachines_timed(nanomachine_activation_time)
	
 
## visually deactivating the nanomachines will take some time for them to fade
## out but gameplay wise, it should be instantaneous
func deactivate_nanomachines():
	if nanomachines_active:
		nanomachines_active = false
		nanomachine_hive_aesthetics.deactivate_nanomachines_timed(nanomachine_deactivation_time)


## Indicates whether or not this unit can attack at all
func can_attack():
	return nanomachines_active && super()


func can_attack_target(target_character : Character):
	if not stunned && can_attack():
		for body in melee_area.get_overlapping_bodies():
			if body == target_character or body == target_character.projectile_hitbox:
				return check_los_to_character()


func attack_target(target_character : Character):
	if target_character is Player and player_damaged_aesthetic_effect:
		player_damaged_aesthetic_effect.play_damage_effect()
	
	RPGEventMaster.invoke_damage_event(rpg_mechanics_master.melee_damage.value, target_character, self)


func on_death():
	var wage_cage_gibs = wage_cage_gibs_scene.instantiate()
	Util.force_add_child(Util.get_level(self), wage_cage_gibs)
	wage_cage_gibs.global_position = global_position
	wage_cage_gibs.rotation = $LookStuff.rotation
	wage_cage_gibs.apply_physics_gibs()
	
	super()
