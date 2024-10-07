extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry] = 6
	
	loot_entries.append(LootEntryConstants.scrap_metal_loot_entry)
	loot_entry_weights[LootEntryConstants.scrap_metal_loot_entry] = 2

	loot_entries.append(LootEntryConstants.nuts_n_bolts_loot_entry)
	loot_entry_weights[LootEntryConstants.nuts_n_bolts_loot_entry] = 2
	
	loot_entries.append(LootEntryConstants.single_armour_shard_loot_entry)
	loot_entry_weights[LootEntryConstants.single_armour_shard_loot_entry] = 1
	
	super()
