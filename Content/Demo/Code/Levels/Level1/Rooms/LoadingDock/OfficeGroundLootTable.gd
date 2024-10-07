extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.blue_key_loot_entry)
	loot_entry_weights[LootEntryConstants.blue_key_loot_entry] = 1
	
	# Ammo
	loot_entries.append(LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry] = 3
	
	# Consumables
	# Hold Use
	loot_entries.append(LootEntryConstants.bandage_loot_entry)
	loot_entry_weights[LootEntryConstants.bandage_loot_entry] = 4
	
	loot_entries.append(LootEntryConstants.mageboar_loot_entry)
	loot_entry_weights[LootEntryConstants.mageboar_loot_entry] = 6

	# Morale
	loot_entries.append(LootEntryConstants.donut_loot_entry)
	loot_entry_weights[LootEntryConstants.donut_loot_entry] = 3
	
	# Treasure
	loot_entries.append(LootEntryConstants.scrip_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_small_quantity_loot_entry] = 4
	
	loot_entries.append(LootEntryConstants.scrip_medium_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_medium_quantity_loot_entry] = 2
	
	loot_entries.append(LootEntryConstants.pocket_computer_loot_entry)
	loot_entry_weights[LootEntryConstants.pocket_computer_loot_entry] = 2
	
	loot_entries.append(LootEntryConstants.gift_card_loot_entry)
	loot_entry_weights[LootEntryConstants.gift_card_loot_entry] = 6
	
	
	# Resources
	# Workshop
	loot_entries.append(LootEntryConstants.duct_tape_loot_entry)
	loot_entry_weights[LootEntryConstants.duct_tape_loot_entry] = 5
	
	
	# Combat
	loot_entries.append(LootEntryConstants.gunpowder_loot_entry)
	loot_entry_weights[LootEntryConstants.gunpowder_loot_entry] = 3
	
	loot_entries.append(LootEntryConstants.kevlar_loot_entry)
	loot_entry_weights[LootEntryConstants.kevlar_loot_entry] = 3
	
	super()
