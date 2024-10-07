extends PlayerInventoryUIMenu

class_name LootInventoryUIMaster

const LOOT_STORAGE_UI_NAME = "LootStorageUI"


func open_loot_menu(player_inventory, loot_storage):
	open_player_inventory(player_inventory)
	map_storage_container_ui_by_name(LOOT_STORAGE_UI_NAME, loot_storage)
	
	inventory_container_default_transfer_mapping[player_inventory.main_storage] = loot_storage
	inventory_container_default_transfer_mapping[loot_storage] = player_inventory.main_storage
