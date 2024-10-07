extends Node3D

class_name InventoryObject

# How much room this item takes in inventory, or how large the item holder is
@export var grid_square_width = 0
@export var grid_square_height = 0

func generate_save_dictionary():
	var save_dictionary = {}
	
	save_dictionary[SaveConstants.SCENE_PATH_SAVE_KEY] = scene_file_path

	return save_dictionary
