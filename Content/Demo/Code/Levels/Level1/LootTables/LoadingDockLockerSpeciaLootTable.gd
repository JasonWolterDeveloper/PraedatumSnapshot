extends LootTable

func _ready():
	# Combat
	loot_entries.append(LootEntryConstants.security_vest_loot_entry)
	loot_entry_weights[LootEntryConstants.security_vest_loot_entry] = 4
	
		
	loot_entries.append(LootEntryConstants.backup_pistol_loot_entry)
	loot_entry_weights[LootEntryConstants.backup_pistol_loot_entry] = 2
	
	
	loot_entries.append(LootEntryConstants.blue_key_loot_entry)
	loot_entry_weights[LootEntryConstants.blue_key_loot_entry] = 1
	
	loot_entries.append(LootEntryConstants.gift_card_loot_entry)
	loot_entry_weights[LootEntryConstants.gift_card_loot_entry] = 1
	
	
	super()
