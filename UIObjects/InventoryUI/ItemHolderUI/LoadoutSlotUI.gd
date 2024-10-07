extends ItemHolderUI

# InventoryContainerPanel is an extension of the panel class used to visually represent a a single grid based inventory
# container in WAR's grid based inventory system. Note that this shouldn't be used to represent a load out slot. However
# it is possible that in the future the inventory will contain multiple container inventory grids
class_name LoadoutSlotUI

# The actual loadout slot this container represents
var loadout_slot : LoadoutSlot = null


func update():
	super()
	if loadout_slot:
		build_from_loadout_slot(loadout_slot)


func build_from_loadout_slot(new_loadout_slot):
	loadout_slot = new_loadout_slot
	generate_size_from_grid_squares()
	build_item_domino_from_item()


func build_item_domino_from_item():
	if loadout_slot.get_item():
		var new_item_domino = get_inventory_ui_menu().make_item_domino_from_item(loadout_slot.get_item())
		Util.force_add_child(self, new_item_domino)


func position_item_domino(item_domino, grid_square=null):
	var loadout_slot_center = Rect2(global_position, custom_minimum_size).get_center()
	var item_domino_top_left_position = MathUtil.get_rect_top_left_from_center(loadout_slot_center, item_domino.custom_minimum_size)
	item_domino.global_position = item_domino_top_left_position


# getGridSquareFromPoint(point) returns the grid square the point is currently in
func get_grid_square_from_point(point):
	return Vector2(0, 0)


func get_rounded_grid_square_from_point(point):
	return Vector2(0, 0)


func get_item_holder():
	return loadout_slot


"""

# returns the exact pixel location of the top left hand corner of the given grid square in this panel's coordinate
# system
func getPixelLocationFromGridLocation(gridLocation):
	var pixelLocation = Vector2(gridLocation[0] * self.getGridSquareSize(), gridLocation[1] * self.getGridSquareSize())
	return pixelLocation

func getLoadoutSlot():
	return itemHolder

func setItemHolder(myItemHolder):
	itemHolder = myItemHolder
	populateItemDominoes()

func positionItemDomino(itemDomino, gridSquare=Vector2(0, 0)):
	var rectCenter = Util.getRectCenter(rect_global_position, rect_size)
	var rectPositionForCenter = Util.getRectTopLeftFromCenter(rectCenter, itemDomino.rect_size)
	itemDomino.rect_global_position = rectPositionForCenter
	
# Creates and positions ItemDominoes for every item in the inventory this panel is visualizing, and adds them to
# this panels contents. Does NOT remove the original contents
func populateItemDominoes():
	if getItemHolder().getItem():
		addVisualizationForItem(getItemHolder().getItem())

# updateSIzeFromInventory sets the size of this panel so that it can correctly show all of the tiles in the related
# container's grid.
func updateSizeFromInventory():
	var doesNothing = true

# getRoundedXGridSquareFromPoint(point) returns the x grid line that point is closest to
func getRoundedXGridSquareFromPoint(point):
	return 0

# getXGridSquareFromPoint() returns the x coordinate of the gridsquare the point is within
func getXGridSquareFromPoint(point):
	return 0

# getRoundedYGridSquareFromPoint(point) returns the y grid line that point is closest to
func getRoundedYGridSquareFromPoint(point):
	return 0

# getYGridSquareFromPoint() returns the y coordinate of the gridsquare the point is within
func getYGridSquareFromPoint(point):
	return 0
"""
