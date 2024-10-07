extends Control

class_name InventoryUIObject

var hovered = false

@export var border_size = 1
@export var grid_square_size = 75
@export var grid_square_width = 1 : get = get_grid_square_width
@export var grid_square_height = 1 : get = get_grid_square_height


# Makes the size of this element show the number of grid squares the container
# Has
func generate_size_from_grid_squares():
	var new_size = Vector2((2*border_size) + (grid_square_width*grid_square_size), 
		(2*border_size) + (grid_square_height*grid_square_size))
		
	DebugMaster.log_debug(str(self) + ": Setting Size: " + str(new_size), DebugMaster.INVENTORY_DEBUG_CATEGORY)
	custom_minimum_size = new_size


func get_inventory_ui_menu(node = self):
	if node.get_parent() == null:
		return null
	if node.get_parent() is InventoryUIMenu:
		return node.get_parent()
	return get_inventory_ui_menu(node.get_parent())


func get_grid_square_width():
	return grid_square_width


func get_grid_square_height():
	return grid_square_height

"""

func is_class(type): 
	return type == CustomClassConstants.INVENTORY_CONTAINER_CLASS_NAME or .is_class(type)
	
func get_class():
	return CustomClassConstants.INVENTORY_CONTAINER_CLASS_NAME

# returns the item domino at the given position
func getItemDominoAtPos(pos):
	return null

"""
