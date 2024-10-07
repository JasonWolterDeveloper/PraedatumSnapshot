class_name BaseFacilityLevelUIElement extends HBoxContainer

@export var pip_scene : PackedScene


var base_facility : HomeBaseFacility


func delete_existing_level_pips():
	for my_child in get_children():
		if my_child is BaseFacilityLevelPip:
			remove_child(my_child)
			my_child.queue_free()


func add_level_pips_from_base_facility():
	var total_pips = base_facility.get_max_upgrade_level()
	
	var pip_number = 1
	
	while pip_number <= total_pips:
		var new_pip = pip_scene.instantiate()
		add_child(new_pip)
		if pip_number <= base_facility.current_upgrade_level:
			new_pip.set_full()
		
		pip_number += 1


func update():
	delete_existing_level_pips()
	add_level_pips_from_base_facility()
	


func assign_base_facility(new_base_facility : HomeBaseFacility):
	base_facility = new_base_facility
	update()
