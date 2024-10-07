extends SpawnStringMapper

func _ready():
	spawn_string_to_scene_dictionary["zombie"] = preload("res://Content/Demo/Code/Enemies/WageCage/Zombie.tscn")
