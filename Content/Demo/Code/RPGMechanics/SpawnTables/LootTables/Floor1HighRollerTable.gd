extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.backup_pistol_loot_entry)
	loot_entry_weights[LootEntryConstants.backup_pistol_loot_entry] = 0.2
	
	loot_entries.append(LootEntryConstants.trench_sweeper_loot_entry)
	loot_entry_weights[LootEntryConstants.trench_sweeper_loot_entry] = 0.1

	loot_entries.append(LootEntryConstants.blue_key_loot_entry)
	loot_entry_weights[LootEntryConstants.blue_key_loot_entry] = 0.5

	loot_entries.append(LootEntryConstants.tool_kit_loot_entry)
	loot_entry_weights[LootEntryConstants.tool_kit_loot_entry] = 1
	
	
	super()
