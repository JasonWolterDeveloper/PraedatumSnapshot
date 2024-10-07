extends HomeBaseFacility


var stash_storage_level_1_height = 16


func on_hub_level_entered():
	super()
	size_player_stash()


func upgrade(upgrade_level : int):
	super(upgrade_level)
	size_player_stash()


func size_player_stash():
	match current_upgrade_level:
		1:
			InventoryMaster.get_player_stash().grid_square_height = stash_storage_level_1_height
