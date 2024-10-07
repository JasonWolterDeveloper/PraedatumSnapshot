class_name HealthStat extends RPGSegmentedStat

## The Health Stat consists of a number of health segments. For enemies, they
## will typically only have one health segment, while the player will have
## several. We can export the number of health segments available and populate
## this on ready


func get_current_health():
	return value


func get_max_health():
	return get_max_value()
