extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.soylent_loot_entry)
	loot_entry_weights[LootEntryConstants.soylent_loot_entry] = 40
	
	loot_entries.append(LootEntryConstants.scrip_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_small_quantity_loot_entry] = 40

	loot_entries.append(LootEntryConstants.nuts_n_bolts_loot_entry)
	loot_entry_weights[LootEntryConstants.nuts_n_bolts_loot_entry] = 40
	
	loot_entries.append(LootEntryConstants.electronics_loot_entry)
	loot_entry_weights[LootEntryConstants.electronics_loot_entry] = 30
	
	loot_entries.append(LootEntryConstants.gift_card_loot_entry)
	loot_entry_weights[LootEntryConstants.gift_card_loot_entry] = 15
	
	loot_entries.append(LootEntryConstants.novelity_mug_a_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_a_loot_entry] = 5
	
	loot_entries.append(LootEntryConstants.novelity_mug_b_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_b_loot_entry] = 5
	
	loot_entries.append(LootEntryConstants.novelity_mug_c_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_c_loot_entry] = 5
	
	loot_entries.append(LootEntryConstants.blue_key_loot_entry)
	loot_entry_weights[LootEntryConstants.blue_key_loot_entry] = 2
	
	super()
