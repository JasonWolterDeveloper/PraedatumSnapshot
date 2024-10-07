class_name ExitSpawnPoint extends SpawnPoint


@export var exit_scene : PackedScene


func _ready():
	spawner_type = SpawnConstants.EXIT_SPAWN_TYPE


func spawn_exit():
	spawn(exit_scene)
