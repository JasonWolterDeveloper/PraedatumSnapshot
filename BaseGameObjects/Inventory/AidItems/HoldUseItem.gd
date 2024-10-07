class_name HoldUseItem extends UtilityItem

@export var time_to_use : float = 1.0
@export var alt_time_to_use : float = 1.0
@export var holding_use_message : String = ""
@export var hold_use_message_priority : int = 1

## hold_use_stat_modifiers are stat modifiers that should only be applied if
## we are currently being held down. I.E., slowing your movement speed if
## you are healing yourself
@export var hold_use_stat_modifiers : Array[RPGStatModifier] = []

## hold_use_event_modifiers are event modifiers that should only be applied if
## we are currently being held down. I.E., lowering damage if you are holding
## up your shield
@export var hold_use_event_modifiers : Array[RPGEventModifier] = []

var is_held : bool = false
var current_hold_time : float = 0.0
# Whether or not our hold event has occured yet
var hold_fired : bool = false

var is_alt_held : bool = false
var current_alt_hold_time : float = 0.0
# Whether or not our hold alt event has occured yet
var alt_hold_fired : bool = false

# Combined stat and event modifiers are lists that combine both the non hold
# use and hold use identifiers into one combined array. We do this to make it
# easier to apply both sets of modifiers while our buttin is being held down
var combined_stat_modifiers : Array[RPGStatModifier] = []
var combined_event_modifiers : Array[RPGEventModifier] = []

# Used to remember our non held stat modifiers. This is so we can reset our
# rpg_stat_modifiers function after we let go of our hold use button
var non_held_stat_modifiers : Array[RPGStatModifier] = []
var non_held_event_modifiers : Array[RPGEventModifier] = []


func _ready():
	super()
	# Populating combined modifier arrays
	for modifier in rpg_stat_modifiers:
		combined_stat_modifiers.append(modifier)
		non_held_stat_modifiers.append(modifier)
	for modifier in hold_use_stat_modifiers:
		combined_stat_modifiers.append(modifier)
	
	for modifier in rpg_event_modifiers:
		combined_event_modifiers.append(modifier)
		non_held_event_modifiers.append(modifier)
	for modifier in hold_use_event_modifiers:
		combined_stat_modifiers.append(modifier)



# --------- Equipped Item Use Functions --------- #


func handle_equipped(delta : float):
	if is_held and not hold_fired:
		OnScreenMessageMaster.display_progress(calculate_progress(), holding_use_message, hold_use_message_priority)
		current_hold_time += delta
		if current_hold_time >= time_to_use:
			use_utility()
			hold_fired = true
	if is_alt_held and not alt_hold_fired:
		current_alt_hold_time += delta
		if current_alt_hold_time >= alt_time_to_use:
			alt_use_utility()
			alt_hold_fired = true


func on_use_item_pressed():
	if can_use_utility():
		is_held = true
		rpg_stat_modifiers = combined_stat_modifiers
		rpg_event_modifiers = combined_event_modifiers
		get_wielder().rpg_mechanics_master.recalculate_stats_for_node(self)
	else:
		show_cannot_use_message()


func on_use_item_released():
	is_held = false
	current_hold_time = 0.0
	hold_fired = false
	rpg_stat_modifiers = non_held_stat_modifiers
	rpg_event_modifiers = non_held_event_modifiers
	# We are recalculating all stats here, because if we recalculate stats for node
	# here, we don't have baseline modifiers. I.E. if we have a movement restriction when we hold
	# use, but no modifier for our regular item, that stat won't get recalculated
	get_wielder().rpg_mechanics_master.recalculate_all_stats()


func on_alt_use_item_pressed():
	if can_alt_use_utility():
		is_alt_held = true
	else:
		show_cannot_alt_use_message()


func on_alt_use_item_released():
	is_alt_held = false
	current_alt_hold_time = 0.0
	alt_hold_fired = false


func can_use_from_inventory():
	return GameMaster.get_level().is_hub_level and super()


func calculate_progress():
	return (current_hold_time/time_to_use * 100.0)


# --------- Getters and Setters --------- #


func get_rpg_stat_modifiers():
	if is_held:
		return combined_stat_modifiers
	return rpg_stat_modifiers
