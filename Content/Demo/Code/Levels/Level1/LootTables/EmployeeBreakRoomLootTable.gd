extends LootTable

func _ready():
	# Ammo
	loot_entries.append(LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry] = 30
	
	# Consumables
	loot_entries.append(LootEntryConstants.mageboar_loot_entry)
	loot_entry_weights[LootEntryConstants.mageboar_loot_entry] = 40

	# Morale
	loot_entries.append(LootEntryConstants.donut_loot_entry)
	loot_entry_weights[LootEntryConstants.donut_loot_entry] = 40
	
	loot_entries.append(LootEntryConstants.cup_of_joe_loot_entry)
	loot_entry_weights[LootEntryConstants.cup_of_joe_loot_entry] = 40
	
	
	# Treasure
	loot_entries.append(LootEntryConstants.scrip_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_small_quantity_loot_entry] = 20
	
	loot_entries.append(LootEntryConstants.scrip_medium_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_medium_quantity_loot_entry] = 20
	
	loot_entries.append(LootEntryConstants.novelity_mug_a_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_a_loot_entry] = 10
	loot_entries.append(LootEntryConstants.novelity_mug_b_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_b_loot_entry] = 10
	loot_entries.append(LootEntryConstants.novelity_mug_c_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_c_loot_entry] = 10
	
	
	# Resources
	# Workshop
	loot_entries.append(LootEntryConstants.ingredients_loot_entry)
	loot_entry_weights[LootEntryConstants.ingredients_loot_entry] = 50
	
	
	super()
