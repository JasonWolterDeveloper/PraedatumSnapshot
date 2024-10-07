extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.trench_sweeper_loot_entry)
	loot_entry_weights[LootEntryConstants.trench_sweeper_loot_entry] = 3
	
	loot_entries.append(LootEntryConstants.barracuda_loot_entry)
	loot_entry_weights[LootEntryConstants.barracuda_loot_entry] = 3

	super()
