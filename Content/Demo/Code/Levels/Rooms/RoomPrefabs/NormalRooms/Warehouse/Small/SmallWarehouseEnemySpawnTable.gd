extends SpawnTable

func _ready():
	# Change spawns by difficulty level here for ease of use
	spawns_by_difficulty_level[0] = [[]]
	spawns_by_difficulty_level[1] = [["wage_cage"],["wage_cage"], ["wage_cage"], ["security_bot"],["wage_cage","wage_cage"]]
	spawns_by_difficulty_level[2] = [["turret"], ["wage_cage"], ["wage_cage"], ["security_bot"], ["security_bot"], ["wage_cage","wage_cage"], ["wage_cage","wage_cage"], ["wage_cage","securit_bot"]]
	spawns_by_difficulty_level[3] = [["turret"], ["wage_cage"], ["wage_cage"], ["security_bot"], ["security_bot"], ["wage_cage","wage_cage"], ["wage_cage","wage_cage"], ["wage_cage","securit_bot"]]
	spawns_by_difficulty_level[4] = [["turret"], ["wage_cage"], ["wage_cage"], ["security_bot"], ["security_bot"], ["wage_cage","wage_cage"], ["wage_cage","wage_cage"], ["wage_cage","securit_bot"]]
	pass
