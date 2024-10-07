class_name ReloadEvent extends RPGEvent

const MAX_PERFECT_ZONE_SIZE = 1.0
const MIN_PERFECT_ZONE_SIZE = 0.1
const MIN_RELOAD_TIME = 0.0

# ----- Parameters -----#
var reload_master : ReloadMaster

# ----- Modifiers -----#
var reload_time_multiplicative_modifier : float = 1.0
var perfect_zone_length_multiplicative_modifier : float = 1.0


func invoke_event():
	if reload_master.weapon.get_weapon_wielder():
		reload_master.weapon.get_weapon_wielder().rpg_mechanics_master.apply_event_modifiers_to_event(self)
		
	reload_master.modified_max_reload_time = max(MIN_RELOAD_TIME, reload_master.max_reload_time * reload_time_multiplicative_modifier)
	reload_master.modified_perfect_zone_length = min(MAX_PERFECT_ZONE_SIZE, max(MIN_PERFECT_ZONE_SIZE, reload_master.perfect_zone_length * perfect_zone_length_multiplicative_modifier))
	DebugMaster.log_debug("Perfect Zone Length: " + str(reload_master.modified_perfect_zone_length))
	super()
