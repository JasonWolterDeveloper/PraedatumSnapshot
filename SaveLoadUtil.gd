extends Node


func load_object_from_object_entry(entry):
	if entry == null:
		return null
	var scene_path = entry[SaveConstants.SCENE_PATH_SAVE_KEY]
	var object_scene : PackedScene = load(scene_path)
	if object_scene:
		var new_object = object_scene.instantiate()
		new_object.load_from_dictionary(entry)
		
		return new_object
	return null


# Returns true only if the save_key is in the dictionary AND if the value of the
# key is NOT null
func check_save_key_exists(load_dictionary, key):
	return load_dictionary.has(key) and load_dictionary[key] != null
