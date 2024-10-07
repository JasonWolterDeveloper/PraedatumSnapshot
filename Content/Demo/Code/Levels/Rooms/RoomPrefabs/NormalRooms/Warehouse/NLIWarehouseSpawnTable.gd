extends SpawnTable

func _ready():
	# Change spawns by difficulty level here for ease of use
	spawns_by_difficulty_level[0] = [[]]
	spawns_by_difficulty_level[1] = [["wage_cage"],["wage_cage"],["wage_cage","wage_cage"],["wage_cage","wage_cage"], ["wage_cage", "wage_cage", "wage_cage"]]
	spawns_by_difficulty_level[2] = [["wage_cage", "turret"],["wage_cage","wage_cage"],["wage_cage","wage_cage"],["wage_cage","wage_cage","turret"],["wage_cage","wage_cage","security_bot"]]
	spawns_by_difficulty_level[3] = [["wage_cage","wage_cage","turret"],["wage_cage","wage_cage","wage_cage"],["wage_cage","wage_cage","wage_cage","turret"],["security_bot","turret"]]
	spawns_by_difficulty_level[4] = [["wage_cage","wage_cage","turret","turret"],["wage_cage","security_bot","turret","turret"],["wage_cage","security_bot","wage_cage","security_bot"]]
	pass
