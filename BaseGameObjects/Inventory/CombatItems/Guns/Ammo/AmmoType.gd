class_name AmmoType extends Resource

# Exported Variables
@export var ammo_type: String = ""
@export var available_subtypes: Array[String] = []

@export var subtype_to_ammo_item_mapping : Dictionary = {}
@export var default_ammo_item_scene : PackedScene


# Returns the next subtype in the list from the given subtype
func cycle_subtype(subtype : String) -> String:
	var current_idx = get_index_for_subtype(subtype)
	if current_idx == -1:
		return get_default_subtype()
	
	var new_idx = current_idx + 1
	if new_idx >= len(available_subtypes):
		return available_subtypes[0]
	return available_subtypes[new_idx]


# Function to get the index of a subtype
func get_index_for_subtype(subtype: String) -> int:
	for i in range(len(available_subtypes)):
		if available_subtypes[i] == subtype:
			return i
	return -1


func get_default_subtype() -> String:
	return available_subtypes[0]


func get_item_scene_for_subtype(subtype : String):
	if subtype_to_ammo_item_mapping.has(subtype):
		return subtype_to_ammo_item_mapping[subtype]
	return default_ammo_item_scene
