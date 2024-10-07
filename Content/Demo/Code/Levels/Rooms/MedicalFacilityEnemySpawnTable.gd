extends SpawnTable

func _ready():
	# Change spawns by difficulty level here for ease of use
	spawns_by_difficulty_level[0].append([])
	spawns_by_difficulty_level[1].append(["zombie"])
	spawns_by_difficulty_level[2].append(["zombie", "zombie"])
	spawns_by_difficulty_level[3].append(["zombie", "zombie", "zombie"])
	pass
