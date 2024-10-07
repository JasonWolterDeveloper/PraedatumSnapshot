extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry] = 3
	
	
	loot_entries.append(LootEntryConstants.shotgun_ammo_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.shotgun_ammo_small_quantity_loot_entry] = 2
	
	
	loot_entries.append(LootEntryConstants.multi_armour_shard_small_loot_entry)
	loot_entry_weights[LootEntryConstants.multi_armour_shard_small_loot_entry] = 2
	
	
	loot_entries.append(LootEntryConstants.donut_loot_entry)
	loot_entry_weights[LootEntryConstants.donut_loot_entry] = 4
	
	
	loot_entries.append(LootEntryConstants.health_potion_loot_entry)
	loot_entry_weights[LootEntryConstants.health_potion_loot_entry] = 1
	
	
	loot_entries.append(LootEntryConstants.scrip_medium_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_medium_quantity_loot_entry] = 2


	super()
