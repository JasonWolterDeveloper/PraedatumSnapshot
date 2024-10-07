class_name BaseSolarPowerUI extends HBoxContainer


@export var power_pip_scene : PackedScene


func update():
	clear_power_pips()
	add_power_pips_from_data_tome()


func clear_power_pips():
	for my_child in get_children():
		if my_child is BaseFacilityPowerPip:
			remove_child(my_child)
			my_child.queue_free()


func add_power_pips_from_data_tome():
	var total_pips = PersistentDataTome.get_max_solar_power()
	var filled_pips = PersistentDataTome.get_current_solar_power()
	
	var pip_number = 0
	
	while pip_number < total_pips:
		var new_pip_scene = power_pip_scene.instantiate()
		add_child(new_pip_scene)
		if pip_number < filled_pips:
			new_pip_scene.set_full()
		
		pip_number += 1
