class_name EnemySpawnPoint extends SpawnPoint

@export var patrol : Patrol
@export var sentry : bool


func _ready():
	if not patrol:
		find_patrol()


func find_patrol():
	for my_child in get_children():
		if my_child is Patrol:
			patrol = my_child


func spawn(object_to_spawn : PackedScene):
	var new_object = object_to_spawn.instantiate()
	new_object.patrol = patrol
	Util.get_level(self).add_child(new_object)
	new_object.global_position = global_position
	used = true
	return new_object

