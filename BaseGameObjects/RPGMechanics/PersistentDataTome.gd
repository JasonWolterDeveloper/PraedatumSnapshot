extends Node
## PersistentDataTome is a global class that holds a whole heap of information about
## where the player is at in their story line and quests. This can be anything from base upgrades
## to shortcuts opened to conversations they've had with NPCS
## All of these must be key value pairs with simple data types, and strings as the keys


# ---------- BASE FACILITY DATA ---------- #
const BASE_FACILITY_TOME_KEY = "base_facilities"
const BASE_FACILITY_CURRENT_POWER_KEY = "current_solar_power"
const BASE_FACILITY_MAX_POWER_KEY = "max_solar_power"

# ---------- WARRIOR DATA ---------- #
const WARRIORS_KEY = "warriors"
const WARRIORS_RPG_STATS_KEY = "warriors_stats"

var tome_of_data : Dictionary = {
	BASE_FACILITY_TOME_KEY : {},
	BASE_FACILITY_CURRENT_POWER_KEY : 2,
	BASE_FACILITY_MAX_POWER_KEY : 2,
	WARRIORS_KEY : {},
	WARRIORS_RPG_STATS_KEY : {}
}


func _ready():
	setup_default_keys()


func setup_default_keys():
	if not has_data_key(BASE_FACILITY_TOME_KEY):
		set_data_for_key(BASE_FACILITY_TOME_KEY, {})


func has_data_key(key : String):
	return tome_of_data.has(key)


func get_data_for_key(key : String):
	if has_data_key(key):
		return tome_of_data[key]
	return null


## Sets the data for a particular key, overwriting previous data if it
## exists. Data must be a primitive data type   
func set_data_for_key(key : String, data):
	assert(Util.is_primitive(data) or data is Dictionary)
	tome_of_data[key] = data


func get_data_for_base_facility_by_id(base_facility_id : String):
	var base_facility_data = get_data_for_key(BASE_FACILITY_TOME_KEY)
	if base_facility_data is Dictionary:
		if base_facility_data.has(base_facility_id):
			return base_facility_data[base_facility_id]
	return null


func set_data_for_base_facility_by_id(base_facility_id : String, data):
	var base_facility_data = get_data_for_key(BASE_FACILITY_TOME_KEY)
	if base_facility_data is Dictionary:
		base_facility_data[base_facility_id] = data


func get_current_solar_power():
	return get_data_for_key(BASE_FACILITY_CURRENT_POWER_KEY)
	
	
func set_current_solar_power(val):
	set_data_for_key(BASE_FACILITY_CURRENT_POWER_KEY, val)


func get_max_solar_power():
	return get_data_for_key(BASE_FACILITY_MAX_POWER_KEY)
	
	
func set_max_solar_power(val):
	set_data_for_key(BASE_FACILITY_MAX_POWER_KEY, val)
	
