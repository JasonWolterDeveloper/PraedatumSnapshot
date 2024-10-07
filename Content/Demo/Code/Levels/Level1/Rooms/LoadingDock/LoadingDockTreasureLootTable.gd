extends LootTable

func _ready():
	loot_entries.append(LootEntryConstants.backup_pistol_loot_entry)
	loot_entry_weights[LootEntryConstants.backup_pistol_loot_entry] = 20

	loot_entries.append(LootEntryConstants.blue_key_loot_entry)
	loot_entry_weights[LootEntryConstants.blue_key_loot_entry] = 100
	
	loot_entries.append(LootEntryConstants.gift_card_loot_entry)
	loot_entry_weights[LootEntryConstants.gift_card_loot_entry] = 80
	
	loot_entries.append(LootEntryConstants.scrip_large_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_large_quantity_loot_entry] = 80
	
	loot_entries.append(LootEntryConstants.novelity_mug_a_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_a_loot_entry] = 10
	loot_entries.append(LootEntryConstants.novelity_mug_b_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_b_loot_entry] = 10
	loot_entries.append(LootEntryConstants.novelity_mug_c_loot_entry)
	loot_entry_weights[LootEntryConstants.novelity_mug_c_loot_entry] = 10
	
	super()

	# loot_entries.append(LootEntryConstants.tool_kit_loot_entry)
	# loot_entry_weights[LootEntryConstants.tool_kit_loot_entry] = 1

	# Ammo
	# loot_entries.append(LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry)
	# loot_entry_weights[LootEntryConstants.small_pistol_ammo_small_quantity_loot_entry] = 3
	
	# loot_entries.append(LootEntryConstants.shotgun_ammo_small_quantity_loot_entry)
	# loot_entry_weights[LootEntryConstants.shotgun_ammo_small_quantity_loot_entry] = 3
	
	# Consumables
	# Instant
	# loot_entries.append(LootEntryConstants.health_potion_loot_entry)
	# loot_entry_weights[LootEntryConstants.health_potion_loot_entry] = 4
	
	# loot_entries.append(LootEntryConstants.mana_potion_loot_entry)
	# loot_entry_weights[LootEntryConstants.mana_potion_loot_entry] = 4
	
	"""
	# Hold Use
	loot_entries.append(LootEntryConstants.bandage_loot_entry)
	loot_entry_weights[LootEntryConstants.bandage_loot_entry] = 4
	
	loot_entries.append(LootEntryConstants.mageboar_loot_entry)
	loot_entry_weights[LootEntryConstants.mageboar_loot_entry] = 4
	
	loot_entries.append(LootEntryConstants.single_armour_shard_loot_entry)
	loot_entry_weights[LootEntryConstants.single_armour_shard_loot_entry] = 4
	
	# Morale
	loot_entries.append(LootEntryConstants.donut_loot_entry)
	loot_entry_weights[LootEntryConstants.donut_loot_entry] = 3
	
	# Treasure
	loot_entries.append(LootEntryConstants.scrip_small_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_small_quantity_loot_entry] = 4
	
	loot_entries.append(LootEntryConstants.scrip_medium_quantity_loot_entry)
	loot_entry_weights[LootEntryConstants.scrip_medium_quantity_loot_entry] = 2
	
	loot_entries.append(LootEntryConstants.pocket_computer_loot_entry)
	loot_entry_weights[LootEntryConstants.pocket_computer_loot_entry] = 6
	
	loot_entries.append(LootEntryConstants.gift_card_loot_entry)
	loot_entry_weights[LootEntryConstants.gift_card_loot_entry] = 2
	
	
	# Resources
	# Workshop
	loot_entries.append(LootEntryConstants.scrap_metal_loot_entry)
	loot_entry_weights[LootEntryConstants.scrap_metal_loot_entry] = 15
	
	loot_entries.append(LootEntryConstants.nuts_n_bolts_loot_entry)
	loot_entry_weights[LootEntryConstants.nuts_n_bolts_loot_entry] = 10
	
	loot_entries.append(LootEntryConstants.duct_tape_loot_entry)
	loot_entry_weights[LootEntryConstants.duct_tape_loot_entry] = 6
	
	# Combat
	loot_entries.append(LootEntryConstants.gunpowder_loot_entry)
	loot_entry_weights[LootEntryConstants.gunpowder_loot_entry] = 5
	
	loot_entries.append(LootEntryConstants.kevlar_loot_entry)
	loot_entry_weights[LootEntryConstants.kevlar_loot_entry] = 2
	"""
