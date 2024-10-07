extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.trench_sweeper_loot_entry)
	loot_entry_weights[LootEntryConstants.trench_sweeper_loot_entry] = 10
	
	loot_entries.append(LootEntryConstants.barracuda_loot_entry)
	loot_entry_weights[LootEntryConstants.barracuda_loot_entry] = 10
	
	loot_entries.append(LootEntryConstants.tool_kit_loot_entry)
	loot_entry_weights[LootEntryConstants.tool_kit_loot_entry] = 10
	
	loot_entries.append(LootEntryConstants.microwave_loot_entry)
	loot_entry_weights[LootEntryConstants.microwave_loot_entry] = 10
	
	loot_entries.append(LootEntryConstants.coffee_maker_loot_entry)
	loot_entry_weights[LootEntryConstants.coffee_maker_loot_entry] = 10
	
	loot_entries.append(LootEntryConstants.tool_kit_loot_entry)
	loot_entry_weights[LootEntryConstants.tool_kit_loot_entry] = 10
	
	loot_entries.append(LootEntryConstants.security_vest_loot_entry)
	loot_entry_weights[LootEntryConstants.security_vest_loot_entry] = 10
	
	super()
