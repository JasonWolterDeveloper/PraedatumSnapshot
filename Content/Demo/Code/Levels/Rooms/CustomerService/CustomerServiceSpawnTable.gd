extends SpawnTable

func _ready():
	# Change spawns by difficulty level here for ease of use
	spawns_by_difficulty_level[0] = [[]]
	spawns_by_difficulty_level[1] = [[],["wage_cage", "wage_cage"],["wage_cage"],["wage_cage"]]
	pass
