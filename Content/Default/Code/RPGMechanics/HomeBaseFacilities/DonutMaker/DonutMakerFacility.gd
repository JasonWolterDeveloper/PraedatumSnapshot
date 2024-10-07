extends HomeBaseFacility


@export var donut_scene : PackedScene
@export var power_cost = 1


func can_use_facility():
	var current_solar =  PersistentDataTome.get_current_solar_power()
	var power = power_cost
	return PersistentDataTome.get_current_solar_power() >= power_cost # current_upgrade_level > 0 and PersistentDataTome.get_current_solar_power() > power_cost


func use_facility_effect():
	var successfully_created_stash = attempt_create_and_add_donut_to_storage(InventoryMaster.get_player_stash())
	
	if not successfully_created_stash:
		var successfully_created = attempt_create_and_add_donut_to_storage(InventoryMaster.get_player_main_storage())
		if not successfully_created:
			OnScreenMessageMaster.display_message("Not enough Stash or Inventory Space")


func attempt_create_and_add_donut_to_storage(storage : Storage):
	var new_donut : MoraleItem = donut_scene.instantiate()
	
	if storage.can_fit_anywhere(new_donut):
		storage.insert_anywhere(new_donut)
		PersistentDataTome.set_current_solar_power(PersistentDataTome.get_current_solar_power() - power_cost)
		return true
	return false
