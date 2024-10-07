extends SpawnTable

func _ready():
	spawns_by_difficulty_level[0].append([])
	
	spawns_by_difficulty_level[1].append(["basic_medical_loot"])
	
	spawns_by_difficulty_level[2].append(["basic_medical_loot"])
