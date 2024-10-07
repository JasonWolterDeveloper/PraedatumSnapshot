extends SpawnStringMapper

func _ready():
	spawn_string_to_scene_dictionary["health_potion"] = preload("res://Content/Demo/Code/Items/Aid/Health/Instant/HealthPotion.tscn")
	spawn_string_to_scene_dictionary["9mm_ammo"] = preload("res://Content/Demo/Code/Items/Ammo/SmallCaliberPistolAmmo.tscn")
	spawn_string_to_scene_dictionary["scrip"] = preload("res://Content/Default/Code/Items/Scrip.tscn")
