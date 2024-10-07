class_name SpawnTable extends Node

@onready var spawn_string_mapper : SpawnStringMapper = $SpawnStringMapper

var spawns_by_difficulty_level = {
	0: [],
	1: [],
	2: [],
	3: [],
	4: [],
	5: [],
	6: [],
	7: [],
	8: [],
	9: [],
	10: []
}
	
func _ready():
	populate_spawn_string_mapper()
	# Change spawns by difficulty level here for ease of use
	pass


func populate_spawn_string_mapper():
	for my_child in get_children():
		if my_child is SpawnStringMapper:
			spawn_string_mapper = my_child


func get_packed_scene_from_spawn_string(spawn_string : String) -> PackedScene:
	if not spawn_string_mapper: #TODO - Currently this can be called before our ready function is called, which is cringe and is why we need to do this
		populate_spawn_string_mapper()
	if spawn_string_mapper.spawn_string_to_scene_dictionary.has(spawn_string):
		return spawn_string_mapper.spawn_string_to_scene_dictionary[spawn_string]
	return null
