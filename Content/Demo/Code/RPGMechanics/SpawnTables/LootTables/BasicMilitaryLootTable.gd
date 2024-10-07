extends LootTable

func _ready():

	loot_entries.append(LootEntryConstants.small_pistol_ammo_medium_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.small_pistol_ammo_medium_quantity_loot_entry] = 3
	
	
	loot_entries.append(LootEntryConstants.shotgun_ammo_medium_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.shotgun_ammo_medium_quantity_loot_entry] = 2
	
	
	loot_entries.append(LootEntryConstants.multi_armour_shard_small_loot_entry)
	loot_entry_weights[LootEntryConstants.multi_armour_shard_small_loot_entry] = 1
	
	
	loot_entries.append(LootEntryConstants.frag_grenade_loot_entry)
	loot_entry_weights[LootEntryConstants.frag_grenade_loot_entry] = 2
	
	
	loot_entries.append(LootEntryConstants.stun_grenade_loot_entry)
	loot_entry_weights[LootEntryConstants.stun_grenade_loot_entry] = 2
	
	super()
