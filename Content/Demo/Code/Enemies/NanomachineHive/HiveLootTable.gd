extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.health_potion_loot_entry)
	loot_entry_weights[LootEntryConstants.health_potion_loot_entry] = 2
	
	loot_entries.append(LootEntryConstants.scrap_metal_loot_entry)
	loot_entry_weights[LootEntryConstants.scrap_metal_loot_entry] = 4

	loot_entries.append(LootEntryConstants.electronics_loot_entry)
	loot_entry_weights[LootEntryConstants.electronics_loot_entry] = 4
	
	loot_entries.append(LootEntryConstants.single_armour_shard_loot_entry)
	loot_entry_weights[LootEntryConstants.single_armour_shard_loot_entry] = 1
	
	super()
