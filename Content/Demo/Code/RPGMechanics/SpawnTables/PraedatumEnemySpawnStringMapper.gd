class_name PraedatumEnemySpawnStringMapper extends SpawnStringMapper


func _ready():
	spawn_string_to_scene_dictionary["wage_cage"] = preload("res://Content/Demo/Code/Enemies/WageCage/Zombie.tscn")
	spawn_string_to_scene_dictionary["security_bot"] = preload("res://Content/Demo/Code/Enemies/SecurityBot/SecurityBotEnemy.tscn")
	spawn_string_to_scene_dictionary["turret"] = preload("res://Content/Demo/Code/Enemies/Turret/TurretEnemy.tscn")

	pass
