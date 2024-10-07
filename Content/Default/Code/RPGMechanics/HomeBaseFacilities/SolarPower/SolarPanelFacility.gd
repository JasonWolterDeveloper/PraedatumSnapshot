extends HomeBaseFacility

var power_per_raid_per_level = [1, 2, 4]


func handle_previous_raid():
	super()
	var new_power_value = PersistentDataTome.get_current_solar_power() + power_per_raid_per_level[current_upgrade_level]
	new_power_value = min(PersistentDataTome.get_max_solar_power(), new_power_value)
	PersistentDataTome.set_current_solar_power(new_power_value)
