class_name SolarBatteryFacility extends HomeBaseFacility


var level_1_battery_size = 4
var level_2_battery_size = 8


func upgrade(upgrade_level : int):
	super(upgrade_level)
	match current_upgrade_level:
		1:
			PersistentDataTome.set_max_solar_power(level_1_battery_size)
		2:
			PersistentDataTome.set_max_solar_power(level_2_battery_size)
