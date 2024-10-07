extends PlayerInventoryUIMenu

class_name LostAndFoundUIMenuMaster

const LOST_AND_FOUND_STORAGE_UI_NAME = "LostAndFoundStorageUI"


func open_lost_and_found_menu(player_inventory : Inventory, lost_and_found_storage : LostAndFoundStorage) -> void:
	open_player_inventory(player_inventory)
	map_storage_container_ui_by_name(LOST_AND_FOUND_STORAGE_UI_NAME, lost_and_found_storage)
	
	inventory_container_default_transfer_mapping[player_inventory.main_storage] = lost_and_found_storage
	inventory_container_default_transfer_mapping[lost_and_found_storage] = player_inventory.main_storage
