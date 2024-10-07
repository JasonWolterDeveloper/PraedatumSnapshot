extends SpawnStringMapper

func _ready():
	# spawn_string_to_scene_dictionary[""] = preload("")
	### Consumables
	# Instant Use
	# Potions
	spawn_string_to_scene_dictionary["health_potion"] = preload("res://Content/Demo/Code/Items/Aid/Health/Instant/HealthPotion.tscn")
	spawn_string_to_scene_dictionary["mana_potion"] = preload("res://Content/Demo/Code/Items/Aid/Mana/Instant/ManaPotion/ManaPotion.tscn")
	
	# Hold Use
	# Armour
	spawn_string_to_scene_dictionary["armour_shard"] = preload("res://BaseGameObjects/Inventory/CombatItems/UtilityItems/ArmourShard.tscn")
	
	# Health
	spawn_string_to_scene_dictionary["bandage"] = preload("res://Content/Demo/Code/Items/Aid/Health/HoldUse/Bandage/Bandage.tscn")
	# spawn_string_to_scene_dictionary[""] = preload("")
	
	# Mana
	spawn_string_to_scene_dictionary["mageboars"] = preload("res://Content/Demo/Code/Items/Aid/Mana/HoldUse/MageboarManasticks/MageboarManasticks.tscn")
	# spawn_string_to_scene_dictionary[""] = preload("")
	
	
	### Morale Consumeables
	spawn_string_to_scene_dictionary["donut"] = preload("res://Content/Demo/Code/Items/Aid/Morale/Donuts/MoraleDonut.tscn")
	spawn_string_to_scene_dictionary["cup_of_joe"] = preload("res://Content/Demo/Code/Items/Aid/Morale/CupOfJoe/CupOfJoe.tscn")
	
	
	### Armour
	spawn_string_to_scene_dictionary["security_vest"] = preload("res://Content/Demo/Code/Items/Armour/SecurityVestArmourItem.tscn")
	
	
	### Backpacks
	spawn_string_to_scene_dictionary["duffel_bag"] = preload("res://Content/Demo/Code/Items/Equipment/Backpacks/DuffelBagBackpack.tscn")
	
	
	### Weapons
	spawn_string_to_scene_dictionary["backup_pistol"] = preload("res://Content/Demo/Code/Items/Weapons/TheBackup/TheBackup.tscn")
	spawn_string_to_scene_dictionary["trench_sweeper"] = preload("res://Content/Demo/Code/Items/Weapons/TrenchSweeper/TrenchSweeper.tscn")
	spawn_string_to_scene_dictionary["ol_reliable"] = preload("res://Content/Demo/Code/Items/Weapons/OlReliable/OlReliable.tscn")
	spawn_string_to_scene_dictionary["barracuda"] = preload("res://Content/Demo/Code/Items/Weapons/Barracuda/Barracuda.tscn")
	
	
	### Ammo
	spawn_string_to_scene_dictionary["9mm_ammo"] = preload("res://Content/Demo/Code/Items/Ammo/SmallCaliberPistolAmmo.tscn")
	spawn_string_to_scene_dictionary["shotgun_ammo"] = preload("res://Content/Demo/Code/Items/Ammo/ShotgunShellAmmo.tscn")
	
	
	### Grenades
	spawn_string_to_scene_dictionary["frag_grenade"] = preload("res://Content/Demo/Code/Items/Weapons/FragGrenade/FragGrenadeItem.tscn")
	spawn_string_to_scene_dictionary["stun_grenade"] = preload("res://Content/Demo/Code/Items/Weapons/StunGrenade/StunGrenadeItem.tscn")
	
	
	### Resource Items
	spawn_string_to_scene_dictionary["scrap_metal"] = preload("res://Content/Demo/Code/Items/ResourceItems/ScrapMetal.tscn")
	spawn_string_to_scene_dictionary["nuts_n_bolts"] = preload("res://Content/Demo/Code/Items/ResourceItems/NutsNBolts.tscn")
	spawn_string_to_scene_dictionary["duct_tape"] = preload("res://Content/Demo/Code/Items/ResourceItems/DuctTape.tscn")
	spawn_string_to_scene_dictionary["gunpowder"] = preload("res://Content/Demo/Code/Items/ResourceItems/GunpowderItem.tscn")
	spawn_string_to_scene_dictionary["ingredients"] = preload("res://Content/Demo/Code/Items/ResourceItems/IngredientsItem.tscn")
	spawn_string_to_scene_dictionary["kevlar"] = preload("res://Content/Demo/Code/Items/ResourceItems/Kevlar.tscn")
	spawn_string_to_scene_dictionary["meds"] = preload("res://Content/Demo/Code/Items/ResourceItems/Meds.tscn")
	spawn_string_to_scene_dictionary["pixie_dust"] = preload("res://Content/Demo/Code/Items/ResourceItems/PixieDust.tscn")
	spawn_string_to_scene_dictionary["electronics"] = preload("res://Content/Demo/Code/Items/ResourceItems/Electronics.tscn")
	
	# Special
	spawn_string_to_scene_dictionary["tool_kit"] = preload("res://Content/Demo/Code/Items/ResourceItems/Special/Toolkit/Toolkit.tscn")
	
	# Food
	spawn_string_to_scene_dictionary["soylent"] = preload("res://Content/Demo/Code/Items/ResourceItems/Special/Food/Soylent.tscn")
	spawn_string_to_scene_dictionary["coffee_maker"] = preload("res://Content/Demo/Code/Items/ResourceItems/Special/Food/CoffeeMaker.tscn")
	spawn_string_to_scene_dictionary["microwave"] = preload("res://Content/Demo/Code/Items/ResourceItems/Special/Food/Microwave.tscn")
	
	
	### Tool Items
	spawn_string_to_scene_dictionary["blue_key"] = preload("res://Content/Demo/Code/Items/Tools/BlueKey.tscn")
	
	
	### Treasuure Items
	spawn_string_to_scene_dictionary["scrip"] = preload("res://Content/Default/Code/Items/Scrip.tscn")
	spawn_string_to_scene_dictionary["gift_card"] = preload("res://Content/Demo/Code/Items/TreasureItems/GiftCard.tscn")
	spawn_string_to_scene_dictionary["pocket_computer"] = preload("res://Content/Demo/Code/Items/TreasureItems/PocketComputer.tscn")
	
	# Mugs
	spawn_string_to_scene_dictionary["novelty_mug_a"] = preload("res://Content/Demo/Code/Items/TreasureItems/NoveltyMugs/NoveltyMugA.tscn")
	spawn_string_to_scene_dictionary["novelty_mug_b"] = preload("res://Content/Demo/Code/Items/TreasureItems/NoveltyMugs/NoveltyMugB.tscn")
	spawn_string_to_scene_dictionary["novelty_mug_c"] = preload("res://Content/Demo/Code/Items/TreasureItems/NoveltyMugs/NoveltyMugC.tscn")
