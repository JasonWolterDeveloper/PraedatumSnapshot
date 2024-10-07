extends InventoryUIMenu

class_name PlayerInventoryUIMenu

const PLAYER_MAIN_STORAGE_STRING = "PlayerMainStorageUI"

const PLAYER_ARMOUR_SLOT_NAME = "PlayerArmourSlotUI"
const PLAYER_BACKPACK_SLOT_NAME = "PlayerBackpackSlotControl"

const HOTBAR_NAME = "Hotbar"


func open_player_inventory(player_inventory : Inventory):
	map_storage_container_ui_by_name(PLAYER_MAIN_STORAGE_STRING, player_inventory.main_storage)
		
	map_loadout_slot_ui_by_name(PLAYER_ARMOUR_SLOT_NAME, player_inventory.armour_slot)
	map_loadout_slot_ui_by_name(PLAYER_BACKPACK_SLOT_NAME, player_inventory.backpack_slot)
	
	inventory_container_default_transfer_mapping[player_inventory.armour_slot] = player_inventory.main_storage
