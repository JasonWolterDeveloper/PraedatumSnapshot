## The HomeBaseFacilityMaster is a global singleton used to manage HomeBaseFacilities
## It keeps track of all of the HomeBaseFacilitis in play and offers a variety of
## helper functions for all of them, such as saving and loading
extends Node

var home_base_facility_list : Array[HomeBaseFacility] = []


func clear_home_base_facility_list():
	home_base_facility_list.clear()


func assign_home_base_facility(facility : HomeBaseFacility):
	home_base_facility_list.append(facility)


func handle_previous_raid():
	for my_facility : HomeBaseFacility in home_base_facility_list:
		my_facility.handle_previous_raid()


func on_hub_level_entered():
	for my_facility : HomeBaseFacility in home_base_facility_list:
		my_facility.on_hub_level_entered()


func save_base_facilities_to_persistent_data_tome():
	for my_facility : HomeBaseFacility in home_base_facility_list:
		my_facility.save_to_persistent_data_tome()


func load_base_facilities_to_persistent_data_tome():
	for my_facility : HomeBaseFacility in home_base_facility_list:
		my_facility.load_from_persistent_data_tome()


func get_facility_by_id(id: String) -> HomeBaseFacility:
	for facility : HomeBaseFacility in home_base_facility_list:
		if facility.base_facility_id == id:
			return facility
	return null
