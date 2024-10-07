class_name StashMenu extends InventoryUIMenu

@export var player : Player
@export var stash_storage : StashStorage

@onready var player_main_storage_ui : ItemHolderUI = $PlayerMainStorageUI

@onready var stash_storage_UI : StorageUI = $StashStorageUI
@onready var player_armour_slot_ui : LoadoutSlotUI = $PlayerArmourSlotUI


const PLAYER_MAIN_STORAGE_STRING = "PlayerMainStorageUI"

const PLAYER_ARMOUR_SLOT_NAME = "PlayerArmourSlotUI"
const PLAYER_BACKPACK_SLOT_NAME = "PlayerBackpackSlotControl"

const STASH_STORAGE_UI_NAME = "StashStorageUI"


func prepare_ui(new_player : Player, new_storage : StashStorage):
	player = new_player
	stash_storage = new_storage
	open_player_inventory(player.inventory)
	map_storage_container_ui_by_name(STASH_STORAGE_UI_NAME, stash_storage)

	inventory_container_default_transfer_mapping[player.inventory.armour_slot] = player.inventory.main_storage
	
	inventory_container_default_transfer_mapping[player.inventory.main_storage] = stash_storage
	inventory_container_default_transfer_mapping[stash_storage] = player.inventory.main_storage


func open_player_inventory(player_inventory : Inventory):
	map_storage_container_ui_by_name(PLAYER_MAIN_STORAGE_STRING, player_inventory.main_storage)
		
	map_loadout_slot_ui_by_name(PLAYER_ARMOUR_SLOT_NAME, player_inventory.armour_slot)
	map_loadout_slot_ui_by_name(PLAYER_BACKPACK_SLOT_NAME, player_inventory.backpack_slot)
