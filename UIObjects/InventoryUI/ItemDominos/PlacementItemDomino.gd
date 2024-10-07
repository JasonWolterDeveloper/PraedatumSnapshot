extends InventoryUIObject

# The PlacementItemDomino exists solely to display where the item domino will
# be placed in the inventory exactly
class_name PlacementItemDomino

@onready var grid = $ItemDominoGrid

var item = null

func set_item(my_item):
	item = my_item
	generate_size_from_grid_squares()


func notify_can_fit():
	grid.set_to_valid_texture()
	
	
func notify_invalid_position():
	grid.set_to_invalid_texture()
	
	
func notify_can_merge():
	grid.set_to_merge_texture()
	
	
func notify_can_interact():
	grid.set_to_valid_texture()


func get_grid_square_width():
	if item != null:
		return item.grid_square_width
	else:
		return grid_square_width
	
	
func get_grid_square_height():
	if item != null:
		return item.grid_square_height
	else:
		return grid_square_height
		
