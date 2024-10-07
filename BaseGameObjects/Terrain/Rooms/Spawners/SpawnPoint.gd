class_name SpawnPoint extends Node3D

# has this SpawnPoint been used to spawn something
var used : bool = false

var spawner_type = SpawnConstants.ENEMY_SPAWN_TYPE

@export var spawn_white_list : Array[String] = []
@export var spawn_black_list : Array[String] = []


func spawn(object_to_spawn : PackedScene):
	var new_object = object_to_spawn.instantiate()
	Util.get_level(self).add_child(new_object)
	new_object.global_position = global_position
	new_object.global_rotation = global_rotation
	used = true
	return new_object
