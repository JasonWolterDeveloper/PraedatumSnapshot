class_name HubLevel extends Level


@export var lost_and_found_storage : LostAndFoundStorage


func _ready():
	super()
	$UILayer/AvalonMenuBase.prepare_avalon_menu()
	$UILayer/UniversalMenuMaster.set_accepting_input(false)
	setup_base_facility_list()
	HomeBaseFacilityMaster.load_base_facilities_to_persistent_data_tome()
	handle_previous_raid()
	HomeBaseFacilityMaster.on_hub_level_entered()
	$UILayer/AvalonMenuBase.update_all()


func handle_previous_raid():
	if GlobalConfigMaster.has_previous_raid():
		HomeBaseFacilityMaster.handle_previous_raid()
	if GlobalConfigMaster.was_previous_raid_successful():
		handle_successful_previous_raid()
	elif GlobalConfigMaster.was_previous_raid_failure():
		handle_failed_previous_raid()
	GlobalConfigMaster.clear_previous_raid()
	GlobalConfigMaster.save_settings()


func handle_successful_previous_raid():
	pass


func handle_failed_previous_raid():
	player.rpg_mechanics_master.health.restore_stat_to_max()


func add_base_facilities_to_facility_list(node = self):
	for child in node.get_children():
		if child is HomeBaseFacility:
			HomeBaseFacilityMaster.assign_home_base_facility(child)
		add_base_facilities_to_facility_list(child)


func setup_base_facility_list():
	HomeBaseFacilityMaster.clear_home_base_facility_list()
	add_base_facilities_to_facility_list()



# ---------- Getters and Setters ---------- #


func get_lost_and_found_storage() -> LostAndFoundStorage:
	return lost_and_found_storage
